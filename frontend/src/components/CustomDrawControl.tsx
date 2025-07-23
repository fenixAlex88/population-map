import { useState, useEffect } from 'react';
import {
  useMap, useMapEvents,
  Polygon, Polyline, Marker, Tooltip, CircleMarker
} from 'react-leaflet';
import L, { type LatLngTuple } from 'leaflet';

interface Props {
  onPolygonCreated: (coordinates: LatLngTuple[]) => void;
  onPolygonDeleted: () => void;
  isDrawing: boolean;
  setIsDrawing: (drawing: boolean) => void;
  polygonPopulation: number | null;
  errorMessage: string | null;
}

const icon = L.divIcon({ className: 'invisible', iconSize: [0, 0] });

const CustomDrawControl: React.FC<Props> = ({
  onPolygonCreated,
  onPolygonDeleted,
  isDrawing,
  setIsDrawing,
  polygonPopulation,
  errorMessage,
}) => {
  const map = useMap();
  const [points, setPoints] = useState<LatLngTuple[]>([]);
  const [polygon, setPolygon] = useState<LatLngTuple[] | null>(null);

  // Рисование полигона по клику
  useMapEvents({
    click: (e) => {
      const target = e.originalEvent?.target as HTMLElement;
      if (target.closest('.leaflet-draw-toolbar')) return;

      if (!isDrawing) return;
      const { lat, lng } = e.latlng;

      if (points.length === 0) {
        setPoints([[lat, lng]]);
        return;
      }
      setPoints([...points, [lat, lng]]);
    }
  });

  // Добавление панели кнопок через L.Control
  useEffect(() => {
    const control = L.control({ position: 'topright' });

    control.onAdd = () => {
      const container = L.DomUtil.create('div', 'leaflet-draw-toolbar flex flex-col gap-2 m-4');
      L.DomEvent.disableClickPropagation(container);
      L.DomEvent.disableScrollPropagation(container);

      const drawBtn = L.DomUtil.create('button', '', container);
      drawBtn.innerHTML = isDrawing ? '❌' : '📍';
      drawBtn.className = 'bg-white w-14 h-14 rounded shadow text-xl';
      L.DomEvent.disableClickPropagation(drawBtn);
      drawBtn.onclick = () => {
        setPolygon(null);
        onPolygonDeleted();
        setIsDrawing(!isDrawing);
        setPoints([]);
      };

      const delBtn = L.DomUtil.create('button', '', container);
      delBtn.innerHTML = '🗑️';
      delBtn.className = 'bg-white w-14 h-14 rounded shadow text-xl';
      L.DomEvent.disableClickPropagation(delBtn);
      delBtn.onclick = () => {
        setPolygon(null);
        onPolygonDeleted();
        setPoints([]);
      };

      return container;
    };

    control.addTo(map);
    return () => control.remove();
  }, [map, isDrawing, onPolygonDeleted, setIsDrawing]);

  return (
    <>
      {/* Рисование */}
      {points.length > 0 && (
        <>
          <Polyline positions={points} pathOptions={{ color: 'red', dashArray: '5,5' }} />
          {points.map((p, i) => (
            <CircleMarker key={i} center={p} radius={3} color="red" />
          ))}
          {points.length >= 3 && (
            <CircleMarker
              center={points[0]}
              radius={9}
              color="green"
              eventHandlers={{
                click: (e) => {
                  e.originalEvent.stopPropagation(); // Останавливаем всплытие к карте
                  if (isDrawing) {
                    const closed = [...points, points[0]];
                    setPolygon(closed);
                    setPoints([]);
                    setIsDrawing(false);
                    onPolygonCreated(closed);
                  }
                }
              }}
            />
          )}
        </>
      )}

      {/* Готовый полигон с тултипом */}
      {polygon && (
        <>
          <Polygon positions={polygon} pathOptions={{ color: 'red', fillOpacity: 0.3 }} />
          <Marker position={polygon[0]} icon={icon}>
            <Tooltip permanent>
              {errorMessage ? (
                <div><strong>Ошибка:</strong> {errorMessage}</div>
              ) : polygonPopulation !== null ? (
                <div><strong>Население:</strong> {polygonPopulation.toFixed(1)}</div>
              ) : (
                <div><strong>Нет данных</strong></div>
              )}
            </Tooltip>
          </Marker>
        </>
      )}
    </>
  );
};

export default CustomDrawControl;
