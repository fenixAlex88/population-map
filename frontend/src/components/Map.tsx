import { useState } from 'react';
import {
  MapContainer, Rectangle, Marker, Tooltip,
  FeatureGroup, useMapEvents, CircleMarker,
  useMap,
  Polyline,
  ZoomControl
} from 'react-leaflet';
import L, { type LatLngTuple } from 'leaflet';
import CustomDrawControl from './CustomDrawControl';
import type { PopulationData } from '../types';
import 'leaflet/dist/leaflet.css';
import LayerSwitcher from './LayerSwitcher';

const invisibleIcon = L.divIcon({ className: 'invisible-marker', iconSize: [0, 0] });

interface Node {
  id: number;
  name: string;
  longitude: number;
  latitude: number;
}

interface Link {
  id: number;
  name: string;
  geometry: {
    type: 'LineString';
    coordinates: [number, number][];
  };
  color: string;
}

interface BBox {
  north: number;
  south: number;
  west: number;
  east: number;
}

const ViewportLoader: React.FC<{ setNodes: (nodes: Node[]) => void; setLinks: (links: Link[]) => void }> = ({ setNodes, setLinks }) => {
  const map = useMapEvents({
    moveend: async () => {
      const bounds = map.getBounds();
      const bbox: BBox = {
        north: bounds.getNorth(),
        south: bounds.getSouth(),
        west: bounds.getWest(),
        east: bounds.getEast()
      };

      try {
        const [nodesRes, linksRes] = await Promise.all([
          fetch('http://46.53.187.144:8000/nodes/viewport', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(bbox)
          }),
          fetch('http://46.53.187.144:8000/links/viewport', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(bbox)
          })
        ]);

        if (!nodesRes.ok || !linksRes.ok) throw new Error('Ошибка загрузки viewport');

        const nodes: Node[] = await nodesRes.json();
        const links: Link[] = await linksRes.json();

        setNodes(nodes);
        setLinks(links);
      } catch (err) {
        console.error('❌ Ошибка загрузки viewport:', err);
      }
    }
  });

  return null;
};

const ZoomDependentLinks: React.FC<{ links: Link[] }> = ({ links }) => {
  const map = useMap();
  const zoom = map.getZoom();
  if (zoom < 13) return null;

  return (
    <>
      {links.map((link) => (
        <Polyline
          key={link.id}
          positions={link.geometry.coordinates.map(([lon, lat]) => [lat, lon] as LatLngTuple)}
          pathOptions={{ color: link.color, weight: 2 + (zoom - 13), opacity: 0.8 }}
        >
          <Tooltip sticky>
            <span>{link.name}</span>
          </Tooltip>
        </Polyline>
      ))}
    </>
  );
};


const ZoomDependentNodes: React.FC<{ nodes: Node[] }> = ({ nodes }) => {
  const map = useMap();
  const zoom = map.getZoom();

  if (zoom < 13) return null;

  const computeRadius = (zoom: number): number => {
    const minZoom = 13;
    const maxZoom = 18;
    const minRadius = 2.5;
    const maxRadius = 18;

    if (zoom <= minZoom) return minRadius;
    if (zoom >= maxZoom) return maxRadius;

    return ((zoom - minZoom) / (maxZoom - minZoom)) * (maxRadius - minRadius) + minRadius;
  };

  const markerRadius = computeRadius(zoom);

  return (
    <>
      {nodes.map((node) => (
        <CircleMarker
          key={node.id}
          center={[node.latitude, node.longitude]}
          radius={markerRadius}
          pathOptions={{ color: 'white', fillOpacity: 0.9 }}
        >
          <Tooltip sticky>
            <span>{node.name}</span>
          </Tooltip>
        </CircleMarker>
      ))}
    </>
  );
};


const Map: React.FC<{ onPopulationData: (data: PopulationData | null) => void }> = ({ onPopulationData }) => {
  const [tooltipPosition, setTooltipPosition] = useState<LatLngTuple | null>(null);
  const [rectangle, setRectangle] = useState<LatLngTuple[] | null>(null);
  const [populationData, setPopulationData] = useState<PopulationData | null>(null);
  const [polygon, setPolygon] = useState<LatLngTuple[] | null>(null);
  const [polygonPopulation, setPolygonPopulation] = useState<number | null>(null);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isDrawingPolygon, setIsDrawingPolygon] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [nodes, setNodes] = useState<Node[]>([]);
  const [links, setLinks] = useState<Link[]>([]);
  const [mapMode, setMapMode] = useState<'nodes' | 'density'>('nodes');


  const calculateGeodesicArea = (latlngs: LatLngTuple[]): number => {
    const radius = 6378137;
    const coordinates = latlngs.map(([lat, lon]) => [lon * Math.PI / 180, lat * Math.PI / 180]);

    let area = 0;
    for (let i = 0, len = coordinates.length; i < len; i++) {
      const [lon1, lat1] = coordinates[i];
      const [lon2, lat2] = coordinates[(i + 1) % len];
      area += (lon2 - lon1) * (2 + Math.sin(lat1) + Math.sin(lat2));
    }

    return Math.abs(area * radius * radius / 2);
  };

  const handlePolygonCreated = async (coords: LatLngTuple[]) => {
    const area = calculateGeodesicArea(coords);
    if (area > 500_000_000) {
      setErrorMessage('Полигон слишком большой (' + (area / 1_000_000).toFixed(1) + ' > 500 км²)');
      setIsDrawingPolygon(false);
      return;
    }
    if (area < 50_000) {
      setErrorMessage('Полигон слишком маленький (' + (area / 1_000_000).toFixed(3) + ' < 0.05 км²)');
      setIsDrawingPolygon(false);
      return;
    }

    setPolygon(coords);
    setIsLoading(true);
    try {
      const res = await fetch('http://46.53.187.144:8000/population/polygon', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ coordinates: coords })
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setPolygonPopulation(data.total_population);
      setErrorMessage(null);
    } catch (err) {
      setPolygonPopulation(null);
      setErrorMessage(String(err));
    } finally {
      setIsLoading(false);
    }
  };

  const handlePolygonDeleted = () => {
    setTooltipPosition(null);
    setRectangle(null);
    setPolygon(null);
    setPolygonPopulation(null);
    setErrorMessage(null);
  };

  const MapEventsHandler = () => {
    useMapEvents({
      click: async ({ latlng }) => {
        if (isDrawingPolygon) return;
        const { lat, lng } = latlng;

        if (tooltipPosition && Math.abs(lat - tooltipPosition[0]) < 1e-5 && Math.abs(lng - tooltipPosition[1]) < 1e-5) {
          setRectangle(null);
          setTooltipPosition(null);
          setPopulationData(null);
          onPopulationData(null);
          return;
        }

        try {
          const res = await fetch('http://46.53.187.144:8000/population', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ lat, lon: lng })
          });
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          const data: PopulationData = await res.json();
          setPopulationData(data);
          onPopulationData(data);
          setTooltipPosition([lat, lng]);
          setRectangle([
            [data.coordinates.pixel_corners.top_left.lat, data.coordinates.pixel_corners.top_left.lon],
            [data.coordinates.pixel_corners.bottom_right.lat, data.coordinates.pixel_corners.bottom_right.lon],
          ]);
        } catch (err) {
          setPopulationData(null);
          setTooltipPosition(null);
          setRectangle(null);
          onPopulationData(null);
          setErrorMessage(String(err));
        }
      }
    });
    return null;
  };

  return (
    <>
      {/* Переключатель режима */}
      <div className="absolute top-4 left-4 z-[1000] bg-white rounded shadow-md p-2">
        <label htmlFor="map-mode" className="block text-sm font-medium text-gray-700 mb-1">
          Режим карты
        </label>
        <select
          id="map-mode"
          value={mapMode}
          onChange={(e) => {
            const value = e.target.value;
            if (value === 'nodes' || value === 'density') {
              setMapMode(value);
            }
          }}
          className="block w-full px-3 py-2 text-sm border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 bg-white"
        >
          <option value="nodes">Узлы и связи</option>
          <option value="density">Плотность населения</option>
        </select>
      </div>

      <MapContainer
        id='map-container'
        center={[53.9, 27.56]}
        zoom={10}
        zoomControl={false}
        style={{ height: '100vh', width: '100%' }}
        attributionControl={false}
      >
        <ZoomControl position="bottomright" />
        <LayerSwitcher />
        <ViewportLoader setNodes={setNodes} setLinks={setLinks} />
        {mapMode === 'density' && (
          <>
            <FeatureGroup>

              < CustomDrawControl
                onPolygonCreated={handlePolygonCreated}
                onPolygonDeleted={handlePolygonDeleted}
                isDrawing={isDrawingPolygon}
                setIsDrawing={setIsDrawingPolygon}
                polygonPopulation={polygonPopulation}
                errorMessage={errorMessage}
              />

            </FeatureGroup>

            <MapEventsHandler />
          </>)}

        {/* Инфо по нарисованному контуру */}
        {mapMode === 'density' && polygon && (
          <Marker position={polygon[0]} icon={invisibleIcon}>
            <Tooltip permanent>
              <div className="text-sm text-gray-800">
                {isLoading ? (
                  <p><strong>Загрузка...</strong></p>
                ) : errorMessage ? (
                  <p><strong>Ошибка:</strong> {errorMessage}</p>
                ) : polygonPopulation !== null && polygon ? (
                  <>
                    <p><strong>Население в контуре:</strong> {polygonPopulation.toFixed(1)}</p>
                    <p><strong>Площадь контура:</strong> {(calculateGeodesicArea(polygon) / 1e6).toFixed(2)} км²</p>
                    <p><strong>Плотность:</strong> {(polygonPopulation / (calculateGeodesicArea(polygon) / 1e6)).toFixed(1)} чел./км²</p>
                  </>
                ) : (
                  <p><strong>Нет данных</strong></p>
                )}
              </div>
            </Tooltip>
          </Marker>
        )}

        {mapMode === 'density' && rectangle && (
          <Rectangle bounds={rectangle} pathOptions={{ color: 'blue', fillOpacity: 0.2 }} />
        )}

        {/* Отображение плотности */}
        {mapMode === 'density' && populationData && tooltipPosition && (
          <Marker position={tooltipPosition} icon={invisibleIcon}>
            <Tooltip permanent>
              <div className='text-sm'>
                <p><strong>Широта:</strong> {populationData.coordinates.input.lat.toFixed(5)}</p>
                <p><strong>Долгота:</strong> {populationData.coordinates.input.lon.toFixed(5)}</p>
                <p><strong>На гектар:</strong> {populationData.population_per_hectare.toFixed(1)} человек</p>
                <p><strong>Плотность:</strong> {populationData.density_per_km2} чел./км²</p>
              </div>
            </Tooltip>
          </Marker>
        )}

        {/* Отображение узлов и связей */}
        {mapMode === 'nodes' && (
          <>
            <ZoomDependentNodes nodes={nodes} />
            <ZoomDependentLinks links={links} />
          </>
        )}
      </MapContainer>
    </>
  )
}
export default Map;