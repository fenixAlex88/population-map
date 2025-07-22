import Map from './components/Map';
import type { PopulationData } from './types';

function App() {
  const handlePopulationData = (data: PopulationData | null) => {
    console.log('Population data updated:', data);
  };

  return (
    <div className="relative">
      <Map onPopulationData={handlePopulationData} />
    </div>
  );
}

export default App;