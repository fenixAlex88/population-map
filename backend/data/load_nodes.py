import json
import psycopg2
from psycopg2.extras import execute_values
from typing import List, Dict, Any

DB_CONFIG = {
    'dbname': 'osm_belarus',
    'user': 'postgres',
    'password': 'wewrq22ef2',
    'host': 'localhost',
    'port': '5432'
}


def ensure_node_types(conn: psycopg2.extensions.connection, nodes: List[Dict[str, Any]]) -> None:
    cursor = conn.cursor()

    # Получаем уникальные node_type из JSON
    node_types = {
        (
            node['node_type']['id'],
            node['node_type']['name'],
            node['node_type'].get('min_zoom', 8),
            node['node_type'].get('max_zoom', 18),
            json.dumps(node['node_type'].get('zoom_width', {}))
        )
        for node in nodes
    }

    # Получаем уже существующие ID из базы
    cursor.execute("SELECT id FROM node_types")
    existing_ids = set(row[0] for row in cursor.fetchall())

    # Отбираем только отсутствующие
    missing = [nt for nt in node_types if nt[0] not in existing_ids]

    if missing:
        execute_values(cursor, '''
            INSERT INTO node_types (id, name, icon_id, min_zoom, max_zoom, zoom_width)
            VALUES %s
        ''', [(id_, name, None, minz, maxz, zoom_json) for id_, name, minz, maxz, zoom_json in missing])

        print(f"✅ Created {len(missing)} new node_types")

    cursor.close()


def insert_nodes_only(conn: psycopg2.extensions.connection, nodes: List[Dict[str, Any]]) -> None:
    cursor = conn.cursor()
    nodes_data = []

    for node in nodes:
        longitude, latitude = node['geojson']['geometry']['coordinates']
        region_id = node.get('region_id')  # необязательное поле

        nodes_data.append((
            node['id'],
            node['name'],
            node['net_type']['id'],
            node['node_type']['id'],
            node['node_regulation_type']['id'],
            region_id,
            f'SRID=4326;POINT({latitude} {longitude})'
        ))

    execute_values(cursor, '''
        INSERT INTO nodes (
            id, name, net_type_id, node_type_id, node_regulation_type_id, region_id, geom
        )
        VALUES %s
        ON CONFLICT (id) DO NOTHING
    ''', nodes_data)

    conn.commit()
    cursor.close()


def main():
    with open('nodes.json', 'r', encoding='utf-8') as f:
        nodes = json.load(f)

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✅ Connected")

        ensure_node_types(conn, nodes)
        insert_nodes_only(conn, nodes)

        print("✅ Nodes inserted")
    except Exception as e:
        print(f"🚨 Error: {e}")
    finally:
        if conn:
            conn.close()
            print("🔌 Connection closed")


if __name__ == "__main__":
    main()
