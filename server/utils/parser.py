import markdown


def parserMarkdown(command: str):
    md_str = open(f'../public/commands/{command}.md', 'r', encoding='utf-8').read()
    html = markdown.markdown(md_str, extensions=["tables", "fenced_code"])
    html_template = open('./template.html', 'r', encoding='utf-8').read()
    return html_template % html