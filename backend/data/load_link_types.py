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


def insert_link_types(conn: psycopg2.extensions.connection, types: List[Dict[str, Any]]) -> None:
    cursor = conn.cursor()
    types_data = []

    for link_type in types:
        try:
            mobility = link_type['mobility']
            if mobility not in {1, 2, 3, 4, 5}:
                print(
                    f"⚠️ Skip type {link_type['id']} — invalid mobility {mobility}")
                continue

            types_data.append((
                link_type['id'],
                link_type['name'],
                link_type['color'],
                json.dumps(link_type['zoom_width'], ensure_ascii=False),
                mobility
            ))
        except Exception as e:
            print(f"🚨 Ошибка в link_type {link_type.get('id')}: {e}")

    if types_data:
        execute_values(cursor, '''
            INSERT INTO link_types (id, name, color, zoom_width, mobility)
            VALUES %s
            ON CONFLICT (id) DO UPDATE
            SET name = EXCLUDED.name,
                color = EXCLUDED.color,
                zoom_width = EXCLUDED.zoom_width,
                mobility = EXCLUDED.mobility
        ''', types_data)

        conn.commit()
        print(f"✅ Inserted {len(types_data)} link types")

    cursor.close()


def main():
    with open('link_types.json', 'r', encoding='utf-8') as f:
        types = json.load(f)

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✅ Connected")

        insert_link_types(conn, types)
        print("✅ Link types inserted")

    except Exception as e:
        print(f"🚨 Error: {e}")

    finally:
        if conn:
            conn.close()
            print("🔌 Connection closed")


if __name__ == "__main__":
    main()
