import { useState, useEffect } from 'react';
import { useMapEvents, Polyline, CircleMarker } from 'react-leaflet';
import L, { type LatLngTuple } from 'leaflet';

interface CustomDrawControlProps {
  onPolygonCreated: (coordinates: LatLngTuple[]) => void;
  onPolygonDeleted: () => void;
  isDrawing: boolean;
  setIsDrawing: (isDrawing: boolean) => void;
}

const CustomDrawControl: React.FC<CustomDrawControlProps> = ({
  onPolygonCreated,
  onPolygonDeleted,
  isDrawing,
  setIsDrawing,
}) => {
  const [points, setPoints] = useState<LatLngTuple[]>([]);

  const map = useMapEvents({
    click: (e: L.LeafletMouseEvent) => {
      if (!isDrawing) return;

      const { lat, lng } = e.latlng;
      console.log(`Drawing point added: lat = ${ lat }, lon = ${ lng } `);

      // Проверяем, замыкается ли полигон (клик на первую точку)
      if (points.length > 0 && points[0] && Math.abs(lat - points[0][0]) < 0.0001 && Math.abs(lng - points[0][1]) < 0.0001 && points.length >= 3) {
        console.log('Polygon closed by clicking first point');
        onPolygonCreated(points);
        setIsDrawing(false);
        setPoints([]);
        return;
      }

      setPoints((prev) => [...prev, [lat, lng]]);
    },
  });

  // Добавляем кнопки для начала/остановки рисования и удаления
  useEffect(() => {
    console.log('CustomDrawControl mounted');
    const drawControl = L.control({ position: 'topright' });
    drawControl.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-draw-toolbar');
      const button = L.DomUtil.create('a', 'leaflet-draw-draw-polygon', div);
      button.title = isDrawing ? 'Отменить рисование' : 'Нарисовать полигон';
      button.innerHTML = isDrawing ? '❌' : '📍';
      L.DomEvent.on(button, 'click', () => {
        if (isDrawing) {
          console.log('Draw stopped by button');
          if (points.length >= 3) {
            console.log('Completing polygon on cancel');
            const closedPoints = [...points, points[0]]; // Завершаем полигон
            onPolygonCreated(closedPoints);
          } else {
            console.log('Not enough points to form a polygon, resetting');
          }
          setIsDrawing(false);
          setPoints([]);
        } else {
          console.log('Draw started by button');
          setIsDrawing(true);
        }
      });
      return div;
    };
    drawControl.addTo(map);

    const deleteControl = L.control({ position: 'topright' });
    deleteControl.onAdd = () => {
      const div = L.DomUtil.create('div', 'leaflet-draw-toolbar');
      const button = L.DomUtil.create('a', 'leaflet-draw-edit-remove', div);
      button.title = 'Удалить полигон';
      button.innerHTML = '🗑️';
      L.DomEvent.on(button, 'click', () => {
        console.log('Polygon deleted by button');
        onPolygonDeleted();
        setPoints([]);
      });
      return div;
    };
    deleteControl.addTo(map);

    return () => {
      drawControl.remove();
      deleteControl.remove();
    };
  }, [map, isDrawing, setIsDrawing, onPolygonDeleted, points, onPolygonCreated]);

  return (
    <>
      {points.length > 0 && (
        <>
          <Polyline positions={points} pathOptions={{ color: 'red', weight: 2, dashArray: '5, 5' }} />
          {points.map((point, index) => (
            <CircleMarker key={index} center={point} radius={3} color="red" fillOpacity={1} />
          ))}
          {points.length >= 3 && (
            <CircleMarker center={points[0]} radius={5} color="green" fillOpacity={1} />
          )}
        </>
      )}
    </>
  );
};

export default CustomDrawControl;