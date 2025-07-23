import { useEffect, useRef, useState } from 'react';
import { TileLayer } from 'react-leaflet';
import L from 'leaflet';

const LayerSwitcher: React.FC = () => {
	const [layer, setLayer] = useState<'osm' | 'satellite'>('osm');
	const containerRef = useRef<HTMLDivElement>(null);

	useEffect(() => {
		const container = containerRef.current;
		if (container) {
			L.DomEvent.disableClickPropagation(container);
			L.DomEvent.disableScrollPropagation(container);
		}
	}, []);

	return (
		<>
			{layer === 'osm' ? (
				<TileLayer
					url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
					attribution="© OpenStreetMap"
				/>
			) : (
				<TileLayer
					url="https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"
					attribution="Tiles © Esri"
				/>
			)}

			<div
				ref={containerRef}
				className="absolute bottom-4 left-4 z-[1000] bg-white text-sm shadow rounded flex flex-col gap-2 p-2"
			>
				<button
					className={`px-6 py-2 rounded shadow ${layer === 'osm' ? 'bg-blue-800 text-white' : 'bg-gray-100'}`}
					onClick={() => setLayer('osm')}
				>
					<span>🗺️</span>  <span>Карта</span>
				</button>
				<button
					className={`px-6 py-2 rounded shadow ${layer === 'satellite' ? 'bg-blue-800 text-white' : 'bg-gray-100'}`}
					onClick={() => setLayer('satellite')}
				>
					<span>🛰️</span>  <span>Спутник</span>
				</button>
			</div>
		</>
	);
};

export default LayerSwitcher;
