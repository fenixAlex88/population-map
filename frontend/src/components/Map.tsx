import { useState } from 'react';
import { MapContainer, TileLayer, Rectangle, useMapEvents, Tooltip, Marker } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L, { type LatLngTuple } from 'leaflet';
import type { PopulationData } from '../types';

// Невидимая иконка для Marker
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

  const MapEventsHandler = () => {
    useMapEvents({
      click: async (e: L.LeafletMouseEvent) => {
        const { lat, lng } = e.latlng;

        // Закрываем tooltip при повторном клике в той же точке
        if (tooltipPosition && lat === tooltipPosition[0] && lng === tooltipPosition[1]) {
          console.log('Closing tooltip due to same position click');
          setRectangle(null);
          setTooltipPosition(null);
          setPopulationData(null);
          onPopulationData(null);
          return;
        }

        try {
          const response = await fetch('http://46.53.187.182:8000/population', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ lat, lon: lng }),
          });
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }
          const data: PopulationData = await response.json();
          setPopulationData(data);
          onPopulationData(data);

          // Устанавливаем координаты прямоугольника и tooltip
          setRectangle([
            [data.coordinates.pixel_corners.top_left.lat, data.coordinates.pixel_corners.top_left.lon],
            [data.coordinates.pixel_corners.bottom_right.lat, data.coordinates.pixel_corners.bottom_right.lon],
          ]);
          setTooltipPosition([lat, lng]);
        } catch {
          setPopulationData(null);
          setRectangle(null);
          setTooltipPosition(null);
          onPopulationData(null);
        }
      },
    });
    return null;
  };

  return (
    <MapContainer id='map-container'
      center={[53.9, 27.56] as LatLngTuple}
      zoom={10}
      style={{ height: '100vh', width: '100%' }}
      attributionControl={false} // Скрываем атрибуцию
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      />
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
            </div>
          </Tooltip>
        </Marker>
      )}
    </MapContainer>
  );
};

export default Map;