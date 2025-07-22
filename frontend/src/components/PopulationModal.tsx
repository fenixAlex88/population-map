import type {PopulationData} from '../types';

interface PopulationModalProps {
  data: PopulationData | null;
  onClose: () => void;
}

const PopulationModal: React.FC<PopulationModalProps> = ({ data, onClose }) => {
  if (!data) return null;

  return (
    <div className="fixed inset-0 flex items-center justify-center z-[1000]" onClick={onClose}>
      <div className="bg-white p-6 rounded-lg shadow-lg max-w-md w-full" onClick={(e) => e.stopPropagation()}>
        <h2 className="text-xl font-bold mb-4">Информация о населении</h2>
        <p>
          <strong>Координаты:</strong> lat {data.coordinates.input.lat.toFixed(5)}, lon{' '}
          {data.coordinates.input.lon.toFixed(5)}
        </p>
        <p>
          <strong>Население на гектар:</strong> {data.population_per_hectare.toFixed(1)}
        </p>
        <p>
          <strong>Плотность (чел./км²):</strong> {data.density_per_km2}
        </p>
        <button
          onClick={onClose}
          className="mt-4 bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
        >
          Закрыть
        </button>
      </div>
    </div>
  );
};

export default PopulationModal;