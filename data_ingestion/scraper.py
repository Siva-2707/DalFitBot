import requests
from bs4 import BeautifulSoup

def html_to_markdown(soup):
    md = ""

    for element in soup.body.descendants:
        if element.name == 'h1':
            md += f"# {element.get_text(strip=True)}\n\n"
        elif element.name == 'h2':
            md += f"## {element.get_text(strip=True)}\n\n"
        elif element.name == 'h3':
            md += f"### {element.get_text(strip=True)}\n\n"
        elif element.name == 'h4':
            md += f"#### {element.get_text(strip=True)}\n\n"
        elif element.name == 'p':
            md += f"{element.get_text(strip=True)}\n\n"
        elif element.name == 'ul':
            for li in element.find_all('li', recursive=False):
                md += f"- {li.get_text(strip=True)}\n"
            md += "\n"
        elif element.name == 'ol':
            for i, li in enumerate(element.find_all('li', recursive=False), 1):
                md += f"{i}. {li.get_text(strip=True)}\n"
            md += "\n"
        elif element.name == 'a':
            href = element.get('href')
            text = element.get_text(strip=True)
            if href:
                md += f"[{text}]({href})"
        elif element.name == 'img':
            alt = element.get('alt', '')
            src = element.get('src')
            if src:
                md += f"![{alt}]({src})\n\n"
        elif element.name == 'table':
            headers = [th.get_text(strip=True) for th in element.find_all('th')]
            rows = element.find_all('tr')
            if headers:
                md += '| ' + ' | '.join(headers) + ' |\n'
                md += '| ' + ' | '.join(['---'] * len(headers)) + ' |\n'
                for row in rows[1:]:
                    cols = [td.get_text(strip=True) for td in row.find_all(['td', 'th'])]
                    md += '| ' + ' | '.join(cols) + ' |\n'
            md += '\n'

    return md

def get_file_name(url):
    return url.rstrip("/").split("/")[-1].removesuffix(".html")

# --- MAIN ---

list_of_urls = ["https://athletics.dal.ca/facilities/Dalplex/memberships/handbook-and-policies.html",
                'https://athletics.dal.ca/facilities/Dalhousie_Physiotherapy_clinic.html', 
                'https://athletics.dal.ca/facilities/Dalplex/programs-and-training.html', 
                'https://athletics.dal.ca/content/dam/dalhousie/pdf/athletics/memberships/dalplex-contract.pdf', 
                'https://athletics.dal.ca/about-us.html', 
                'https://athletics.dal.ca/facilities/langille-athletic-centre.html', 
                'https://athletics.dal.ca/facilities/facility-rentals.html', 
                'https://athletics.dal.ca/kids-and-camps.html',
                'https://athletics.dal.ca/dalplex_news_events.html', 
                'https://athletics.dal.ca/facilities/Dalplex/memberships.html', 
                'https://athletics.dal.ca/facilities/sexton_gym.html', 
                'https://athletics.dal.ca/facilities/studley_gym_dancestudio.html', 
                'https://athletics.dal.ca/facilities/Dalplex/dalplex-facilities.html', 
                'https://athletics.dal.ca/dalhousie_tigers.html', 
                'https://athletics.dal.ca/campus-recreation.html', 
                'https://athletics.dal.ca/facilities/Dalplex/hours.html', 
                'https://athletics.dal.ca/facilities/Dalplex.html', 
                'https://athletics.dal.ca/', 
                'https://athletics.dal.ca/facilities.html', 
                'https://athletics.dal.ca/facilities/wickwire_field.html', 
                'https://athletics.dal.ca/rams.html',
                'https://athletics.dal.ca/facilities/Dalplex/memberships/membership_rates.html',
                'https://athletics.dal.ca/facilities/Dalplex/memberships/day_passes.html']

url = "https://athletics.dal.ca/facilities/Dalplex/memberships/handbook-and-policies.html"


for url in list_of_urls:
    response = requests.get(url)

    if response.status_code != 200 or "text/html" not in response.headers.get("Content-Type", ""):
            print(f"❌ Skipping non-HTML or failed URL: {url}")
            continue
    
    soup = BeautifulSoup(response.text, "html.parser")
    markdown_output = html_to_markdown(soup)

    if not markdown_output.strip():
            print(f"⚠️ No markdown content generated for: {url}")
            continue

    file_name = get_file_name(url)
    # Save to .md file
    with open(f"./scraped/{file_name}.md", "w", encoding="utf-8") as file:
        file.write(markdown_output)
    print(f"✅ Markdown saved to '{file_name}.md'")
