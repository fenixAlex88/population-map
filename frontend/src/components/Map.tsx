import { useState, useEffect, useCallback } from 'react';
import { MapContainer, TileLayer, Rectangle, useMapEvents, Tooltip, Marker, FeatureGroup, Polyline } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L, { type LatLngTuple } from 'leaflet';
import CustomDrawControl from './CustomDrawControl';
import type { PopulationData } from '../types';

const invisibleIcon = L.divIcon({
  className: 'invisible-marker',
  iconSize: [0, 0],
  iconAnchor: [0, 0],
});

interface MapProps {
  onPopulationData: (data: PopulationData | null) => void;
}

const Map: React.FC<MapProps> = ({ onPopulationData }) => {
  const [rectangle, setRectangle] = useState<LatLngTuple[] | null>(null);
  const [tooltipPosition, setTooltipPosition] = useState<LatLngTuple | null>(null);
  const [populationData, setPopulationData] = useState<PopulationData | null>(null);
  const [polygon, setPolygon] = useState<LatLngTuple[] | null>(null);
  const [polygonPopulation, setPolygonPopulation] = useState<number | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isDrawingPolygon, setIsDrawingPolygon] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    console.log('isDrawingPolygon changed:', isDrawingPolygon);
  }, [isDrawingPolygon]);

  const MapEventsHandler = () => {
    const map = useMapEvents({
      click: async (e: L.LeafletMouseEvent) => {
        if (isDrawingPolygon) {
          console.log('Click ignored: drawing polygon in progress');
          return;
        }

        const { lat, lng } = e.latlng;
        console.log(`Map clicked at coordinates: lat = ${ lat }, lon = ${ lng } `);

        if (tooltipPosition && Math.abs(lat - tooltipPosition[0]) < 0.00001 && Math.abs(lng - tooltipPosition[1]) < 0.00001) {
          console.log('Closing tooltip due to same position click');
          setRectangle(null);
          setTooltipPosition(null);
          setPopulationData(null);
          onPopulationData(null);
          return;
        }

        try {
          console.log('Sending POST request to http://localhost:8000/population', { lat, lon: lng });
          const response = await fetch('http://localhost:8000/population', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ lat, lon: lng }),
          });

          if (!response.ok) {
            throw new Error(`HTTP error! status: ${ response.status } `);
          }

          const data: PopulationData = await response.json();
          console.log('Received response:', data);
          setPopulationData(data);
          onPopulationData(data);

          setRectangle([
            [data.coordinates.pixel_corners.top_left.lat, data.coordinates.pixel_corners.top_left.lon],
            [data.coordinates.pixel_corners.bottom_right.lat, data.coordinates.pixel_corners.bottom_right.lon],
          ]);
          setTooltipPosition([lat, lng]);
        } catch (error) {
          const message = error instanceof Error ? error.message : String(error);
          console.error('Error fetching population data:', message);
          setPopulationData(null);
          setRectangle(null);
          setTooltipPosition(null);
          onPopulationData(null);
        }
      },
    });
    return null;
  };

  const handlePolygonCreated = useCallback(async (coordinates: LatLngTuple[]) => {
    console.log('Polygon creation triggered at:', new Date().toISOString());
    const latlngs = coordinates.map(([lat, lng]) => L.latLng(lat, lng));
    const polygonArea = L.GeometryUtil.geodesicArea(latlngs); // m²
    if (polygonArea > 100000000) { // 100 km²
      setErrorMessage('Полигон слишком большой, выберите меньшую область');
      console.error('Polygon too large:', polygonArea);
      setIsDrawingPolygon(false);
      return;
    }

    setPolygon(coordinates);
    console.log('Polygon created with coordinates:', coordinates);

    setIsLoading(true);
    try {
      console.log('Sending POST request to http://localhost:8000/population/polygon', { coordinates });
      const response = await fetch('http://localhost:8000/population/polygon', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ coordinates }),
      });
      console.log('Polygon response:', response);
      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`HTTP error! status: ${ response.status }, detail: ${ errorData.detail || 'Unknown error' } `);
      }
      const data = await response.json();
      console.log('Received polygon population:', data);
      setPolygonPopulation(data.total_population);
      setErrorMessage(null);
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.error('Error fetching polygon population:', message);
      setErrorMessage(message);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const handlePolygonDeleted = useCallback(() => {
    console.log('Polygon deleted at:', new Date().toISOString());
    setPolygon(null);
    setPolygonPopulation(null);
    setErrorMessage(null);
  }, []);

  return (
    <MapContainer
      center={[53.9, 27.56] as LatLngTuple}
      zoom={10}
      style={{ height: '100vh', width: '100%' }}
      attributionControl={false}
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      />
      <FeatureGroup>
        <CustomDrawControl
          onPolygonCreated={handlePolygonCreated}
          onPolygonDeleted={handlePolygonDeleted}
          isDrawing={isDrawingPolygon}
          setIsDrawing={setIsDrawingPolygon}
        />
        {polygon && (
          <>
            <Polyline positions={polygon} pathOptions={{ color: 'red', weight: 2, fillOpacity: 0.2 }} />
            <Marker position={polygon[0]} icon={invisibleIcon}>
              <Tooltip permanent>
                <div className="text-sm text-gray-800">
                  {isLoading ? (
                    <p><strong>Загрузка...</strong></p>
                  ) : errorMessage ? (
                    <p><strong>Ошибка:</strong> {errorMessage}</p>
                  ) : (
                    <p>
                      <strong>Общее население в полигоне:</strong>{' '}
                      {polygonPopulation !== null ? polygonPopulation.toFixed(1) : 'Нет данных'}
                    </p>
                  )}
                </div>
              </Tooltip>
            </Marker>
          </>
        )}
      </FeatureGroup>
      <MapEventsHandler />
      {rectangle && (
        <Rectangle
          bounds={rectangle}
          pathOptions={{ color: 'blue', weight: 2, fillOpacity: 0.2 }}
        />
      )}
      {populationData && tooltipPosition && (
        <Marker position={tooltipPosition} icon={invisibleIcon}>
          <Tooltip permanent>
            <div className="text-sm text-gray-800">
              <p>
                <strong>Координаты:</strong> lat {populationData.coordinates.input.lat.toFixed(5)}, lon{' '}
                {populationData.coordinates.input.lon.toFixed(5)}
              </p>
              <p>
                <strong>Население на гектар:</strong> {populationData.population_per_hectare.toFixed(1)}
              </p>
              <p>
                <strong>Плотность (чел./км²):</strong> {populationData.density_per_km2}
              </p>
              <p>
                <strong>Верхний левый угол:</strong> lat {populationData.coordinates.pixel_corners.top_left.lat.toFixed(5)}, lon{' '}
                {populationData.coordinates.pixel_corners.top_left.lon.toFixed(5)}
              </p>
              <p>
                <strong>Нижний правый угол:</strong> lat {populationData.coordinates.pixel_corners.bottom_right.lat.toFixed(5)}, lon{' '}
                {populationData.coordinates.pixel_corners.bottom_right.lon.toFixed(5)}
              </p>
            </div>
          </Tooltip>
        </Marker>
      )}
    </MapContainer>
  );
};

export default Map;