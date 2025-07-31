import subprocess
import shlex
import os

# ───────────── Параметры ─────────────

SRC_TIF = "GHS_BUILT_S_E2030_GLOBE_R2023A_54009_100_V1_0.tif"
# если нужно сначала перепроецировать — сделайте через GDAL/warp
REPROJ_TIF = "reprojected_4326.tif"
DB_HOST = "localhost"
DB_NAME = "gisdb"
DB_USER = "postgres"
DB_PASS = "postgres"
TABLE = "builtup_tiles"

# ───────────── Генерация перепроекции (если ещё не сделали) ─────────────
os.system(f"gdalwarp -t_srs EPSG:4326 {SRC_TIF} {REPROJ_TIF}")

# ───────────── Основная загрузка через raster2pgsql ─────────────


def load_with_raster2pgsql(raster_path):
    # Собираем команду
    cmd = (
        f"raster2pgsql "
        f"-s 4326 "                # указать нужный SRID
        f"-I "                     # создать GIST-индекс
        f"-C "                     # vacuum analyze после вставки
        f"-t 512x512 "            # нарезать на тайлы 512×512
        f"'{raster_path}' "
        f"public.{TABLE}"
    )

    # Конвейер в psql
    psql = (
        f"PGPASSWORD='{DB_PASS}' "
        f"psql -h {DB_HOST} -U {DB_USER} -d {DB_NAME}"
    )

    # Запускаем raster2pgsql | psql
    raster2pgsql = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE)
    psql_proc = subprocess.Popen(
        shlex.split(psql),
        stdin=raster2pgsql.stdout
    )
    raster2pgsql.stdout.close()
    psql_proc.communicate()

    if psql_proc.returncode == 0:
        print("Загрузка завершена успешно")
    else:
        print("Ошибка при загрузке, код:", psql_proc.returncode)


if __name__ == "__main__":
    load_with_raster2pgsql(REPROJ_TIF)
