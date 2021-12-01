/* url transform */

function strip_suffix(str, suffix) {
  if (str.endsWith(suffix)) return str.slice(0, -suffix.length)
  else return str
}

function strip_path_ending(path) {
  const path_parts = path.split('#')
  return [strip_suffix(path_parts[0], '.html'), ...path_parts.slice(1)].join('#')
}

function get_target(url, href) {
  const href_parts = href.split('/')

  if (href_parts.length === 1) return '#' + strip_path_ending(href_parts[0])
  else if (href_parts.length === 3 && href_parts[0] === '..' && href_parts[1] !== '..') {
    return '/entries/' + href_parts[1].toLowerCase() + '/theories#' + strip_path_ending(href_parts[2])
  }
  else return url.split('/').slice(0, -1).join('/') + '/' + href
}

function translate(thy_name, url, content) {
  for (const span of content.getElementsByTagName('span')) {
    let id = span.getAttribute('id')
    if (id) span.setAttribute('id', thy_name + "#" + id)
  }
  for (const link of content.getElementsByTagName('a')) {
    const href = link.getAttribute('href')
    let target = get_target(url, href)
    link.setAttribute('href', target)
  }
}


/* theory lazy-loading */

function parse_doc(html_str) {
  const parser = new DOMParser()
  return parser.parseFromString(html_str, 'text/html')
}

async function fetch_theory(href) {
  return fetch(href).then((http_res) => {
    if (http_res.status !== 200) return Promise.resolve(`<body>${http_res.statusText}</body>`)
    else return http_res.text()
  }).catch((_) => window.location.replace(href))
}

async function fetch_theory_body(href) {
  const html_str = await fetch_theory(href)
  const html = parse_doc(html_str)
  return html.getElementsByTagName('body')[0]
}

async function load_theory(thy_name, href) {
  const thy_body = await fetch_theory_body(href)
  translate(thy_name, href, thy_body)
  const content = theory_content(thy_name)
  content.append(...Array(...thy_body.children).slice(1))
}


/* theory controls */

function parse_elem(html_str) {
  const template = document.createElement('template')
  template.innerHTML = html_str
  return template.content
}

function theory_content(thy_name) {
  const elem = document.getElementById(thy_name)
  if (elem && elem.className === "thy-collapsible") return elem.firstElementChild.nextElementSibling
  else return null
}

async function open_theory(thy_name) {
  const content = theory_content(thy_name)
  if (content) {
    if (content.style.display === 'none') content.style.display = "block"
  }
  else {
    const elem = document.getElementById(thy_name)
    if (elem && elem.className === "thy-collapsible") {
      const content = parse_elem(`<div id="content" style="display: block"></div>`)
      elem.appendChild(content)
      await load_theory(thy_name, elem.getAttribute('datasrc'))
    }
  }
}

const toggle_theory = async function (thy_name) {
  const content = theory_content(thy_name)
  if (content && content.style.display === 'block') content.style.display = 'none'
  else {
    const hash = `#${thy_name}`
    if (window.location.hash === hash) await open_theory(thy_name)
    else window.location.hash = hash
  }
}


/* fragment controls */

function follow_hash(hash) {
  if (hash !== '') {
    const elem = document.getElementById(hash)
    if (elem) {
      console.log("Scrolling into " + hash)
      elem.scrollIntoView()
    }
  }
}

const follow_theory_hash = async function () {
  const hash = window.location.hash
  if (hash.length > 1) {
    const hashes = hash.split('#')
    const thy_name = hashes[1]
    await open_theory(thy_name)
    follow_hash(hashes.slice(1).join('#'))
  }
}


/* setup */

const init = async function () {
  const theory_list = document.getElementById('html-theories')
  if (theory_list) {
    for (const theory of theory_list.children) {
      const thy_link = theory.firstElementChild

      const href = thy_link.getAttribute('href')
      const thy_name = thy_link.innerHTML

      const thy_collapsible = parse_elem(`
        <div id=${thy_name} class="thy-collapsible" datasrc=${href}>
          <div class="head" style="cursor: pointer" onclick="toggle_theory('${thy_name}')">
              <h1>${thy_name}</h1>
          </div>
        </div>`)
      theory.replaceWith(thy_collapsible)
    }
  }
  await follow_theory_hash()
}

window.onload = init
window.onhashchange = follow_theory_hash
