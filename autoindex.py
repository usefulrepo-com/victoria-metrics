from pathlib import Path
from collections import defaultdict


def collect_file_info(root_path):
    """
    Returns Dict[Path, set[Tuple[str, int, float]]] where:
    - Key is a relative directory path from the root containing these files.
    - Value is a set of tuples for each file and directory with their name, size (accumulated), and ctime.
    """
    root = Path(root_path)
    file_info = defaultdict(set)

    # Collect file info
    paths = {path: path.stat() for path in root.rglob('*') if path.is_file()}
    
    # Calculate directory sizes including contents
    dir_sizes = defaultdict(int)
    for path, stat in paths.items():
        size = stat.st_size
        while path.parent != root:
            dir_sizes[path.parent] += size
            path = path.parent

    # Collect info for directories and include accumulated sizes
    for path in root.rglob('*'):
        if any([part.startswith(".") for part in path.parts]):
            continue

        if path.is_dir():
            size = dir_sizes[path]
            ctime = path.stat().st_ctime
        elif path.is_file():
            if path.name in ("index.html",):
                continue

            stat = paths[path]
            size = stat.st_size
            ctime = stat.st_ctime
        else:
            continue

        relative_dir = path.parent.relative_to(root)
        file_info[relative_dir].add((path.name, size, ctime, path.is_dir()))

    return file_info


STYLE = """
<style>
\tbody { font-family: 'Consolas', 'Monaco', monospace; background-color: #272822; color: #F8F8F2; }
\ta { color: #66D9EF; text-decoration: none; }
\ttable { width: 100%; border-collapse: collapse; }
\ttr:hover { background-color: #373832 !important; }
\tth, td { padding: 8px; text-align: left; border-bottom: 1px solid #75715E; }
\tth { font-size: 16px; } 
\ttd { font-size: 14px; }
\t.file::before { content: '\\1F4C4'; margin-right: 10px; }
\t.file-parent::before { content: '\\1F53C'; }
\t.file-directory::before { content: '\\1F4C1'; }
\t.file-deb::before { content: '\\1F4E6'; }
\t.file-gpg::before, .file-asc::before { content: '\\1F510'; }
\t.file-gz::before, .file-bz2::before { content: '\\1F5C4'; }

\t.last-modified, .last-modified-header { display: table-cell; }
\t@media (max-width: 600px) { .last-modified, .last-modified-header { display: none; }
}
</style>
"""


SCRIPTS = """
<script type="text/javascript">
(function() {
\tfunction formatBytes(bytes, decimals) {
\t\tif (bytes === 0) return '0 Bytes';
\t\tvar k = 1024,
\t\t\tdm = decimals <= 0 ? 0 : decimals || 2,
\t\t\tsizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
\t\t\ti = Math.floor(Math.log(bytes) / Math.log(k));
\t\treturn parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
\t}
\tfunction timeSince(timestamp) {
\t\tvar now = Math.floor(Date.now() / 1000);
\t\tvar secondsPast = now - timestamp;
\t\tif (secondsPast < 60) {
\t\t\treturn 'just now';
\t\t} else if (secondsPast < 3600) {
\t\t\tvar minutes = Math.floor(secondsPast / 60);
\t\t\treturn minutes + ' minute' + (minutes > 1 ? 's' : '') + ' ago';
\t\t} else if (secondsPast < 86400) {
\t\t\tvar hours = Math.floor(secondsPast / 3600);
\t\t\treturn hours + ' hour' + (hours > 1 ? 's' : '') + ' ago';
\t\t} else if (secondsPast < 2592000) {
\t\t\tvar days = Math.floor(secondsPast / 86400);
\t\t\treturn days + ' day' + (days > 1 ? 's' : '') + ' ago';
\t\t} else {
\t\t\tvar date = new Date(timestamp * 1000);
\t\t\tvar day = date.getUTCDate();
\t\t\tvar month = date.getUTCMonth() + 1;
\t\t\tvar year = date.getUTCFullYear();
\t\t\tif (secondsPast < 31536000) { return day + '.' + month; } else { return day + '-' + month + '-' + year; }
\t\t}
\t}
\tArray.prototype.forEach.call(
\t\tdocument.getElementsByClassName('last-modified'),
\t\tfunction(element) { element.textContent = timeSince(parseInt(element.textContent)); }
\t);
\tArray.prototype.forEach.call(
\t\tdocument.getElementsByClassName('file-size'),
\t\tfunction(element) { element.textContent = formatBytes(parseInt(element.textContent)); }
\t);
})();
</script>
"""


def generate_directory_index(root_path):
    """
    Render index.html files in each directory with a simple HTML file listing all files.
    """
    root = Path(root_path)
    file_info = collect_file_info(root)
    
    for dir_path, files in file_info.items():
        with (root / dir_path / "index.html").open("w") as index_file:
            path_name = str(dir_path) if dir_path != Path(".") else ''
            index_file.write("<html lang=en>\n<head>\n")
            index_file.write("<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">\n")
            index_file.write(f"<title>Index of {path_name}/</title>\n{STYLE}</head>\n<body>")
            index_file.write("\n\t<h1>")

            index_file.write('<a href="/">/</a>')

            for idx, part in enumerate(dir_path.parts):
                link = "../" * (len(dir_path.parts) - idx - 1)
                index_file.write(f"<a href=\"{link}\">{part}</a>/")
            index_file.write("</h1>\n")
            index_file.write(
                "\n\t<table>\n\t\t<tr>\n\t\t\t<th>Name</th>\n\t\t\t"
                "<th class=\"last-modified-header\">Last Modified</th>\n\t\t\t<th>Size</th>\n\t\t</tr>\n"
            )

            if dir_path != Path("."):
                index_file.write(
                    '\t\t<tr>\n\t\t\t<td><a href=".." class="file-parent file">..</a>'
                    '</td>\n\t\t\t<td class="last-modified-header">—</td>\n\t\t\t<td>—</td>\n\t\t</tr>\n'
                )

            for file_name, size, ctime, is_dir in sorted(files, key=lambda x: (not x[-1], x[0])):
                last_modified = int(ctime)
                if not is_dir:
                    extension = file_name.split('.')[-1] if '.' in file_name else ''
                else:
                    extension = 'directory'
                    file_name = file_name + "/"
                index_file.write(
                    f'\t\t<tr>\n\t\t\t<td>'
                    f'<a href="{file_name}" class="file-{extension} file">{file_name}</a></td>\n'
                    f'\t\t\t<td class="last-modified">{last_modified}</td>\n'
                    f'\t\t\t<td class="file-size">{size}</td>\n\t\t'
                    f'</tr>\n'
                )
            index_file.write(f"\t</table>\n</body>\n{SCRIPTS}\n</html>\n")


if __name__ == "__main__":
    import sys
    root_directory = sys.argv[1]
    generate_directory_index(root_directory)
