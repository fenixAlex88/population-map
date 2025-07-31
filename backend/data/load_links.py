import json
import psycopg2
from psycopg2.extras import execute_values
from typing import List, Dict, Any
from shapely.geometry import LineString

DB_CONFIG = {
    'dbname': 'osm_belarus',
    'user': 'postgres',
    'password': 'wewrq22ef2',
    'host': 'localhost',
    'port': '5432'
}


def insert_links(conn: psycopg2.extensions.connection, links: List[Dict[str, Any]]) -> None:
    cursor = conn.cursor()
    links_data = []

    # Получаем существующие node_ids
    cursor.execute("SELECT id FROM nodes")
    valid_node_ids = set(row[0] for row in cursor.fetchall())

    for link in links:
        try:
            node_a_id = link['node_a']['id']
            node_c_id = link['node_c']['id']

            # Пропускаем, если хотя бы один узел отсутствует
            if node_a_id not in valid_node_ids or node_c_id not in valid_node_ids:
                print(
                    f"⚠️ Skip link {link['id']} — missing node {node_a_id if node_a_id not in valid_node_ids else node_c_id}")
                continue

            coords = link['geojson']['geometry']['coordinates']
            geom = LineString([(c[1], c[0]) for c in coords])  # (lon, lat)
            geom_text = f"SRID=4326;{geom.wkt}"

            links_data.append((
                link['id'],
                link['name'],
                link['net_type']['id'],
                link['link_type_id'],
                node_a_id,
                link['node_a_direction'],
                node_c_id,
                link['node_c_direction'],
                link['gravity'],
                link['one_way_traffic'],
                link.get('osm_ref'),
                link.get('node_a_distance'),
                link.get('node_c_distance'),
                geom_text,
                None  # zone_geom
            ))

        except Exception as e:
            print(f"🚨 Ошибка в link {link.get('id')}: {e}")

    if links_data:
        execute_values(cursor, '''
            INSERT INTO links (
                id, name, net_type_id, link_type_id,
                node_a_id, node_a_direction, node_c_id, node_c_direction,
                gravity, one_way_traffic, osm_ref,
                node_a_distance, node_c_distance,
                geom, zone_geom
            ) VALUES %s
            ON CONFLICT (id) DO NOTHING
        ''', links_data)

        conn.commit()
        print(f"✅ Inserted {len(links_data)} links")

    cursor.close()


def main():
    with open('links.json', 'r', encoding='utf-8') as f:
        links = json.load(f)

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✅ Connected")

        insert_links(conn, links)
        print("✅ Links inserted")

    except Exception as e:
        print(f"🚨 Error: {e}")

    finally:
        if conn:
            conn.close()
            print("🔌 Connection closed")


if __name__ == "__main__":
    main()
