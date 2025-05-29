import re

def extract_urls_from_file(file_path):
    url_pattern = r'https?://athletics[^\s)>\]"]+'  # Regex pattern for URLs

    unique_urls = set()

    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            found_urls = re.findall(url_pattern, line)
            unique_urls.update(found_urls)

    return list(unique_urls) 

print(extract_urls_from_file('full_scraped_page.md'))