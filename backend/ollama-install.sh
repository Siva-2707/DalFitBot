






<!doctype html>
<html class="h-full overflow-y-scroll">
  <head>
    <title>Download Ollama on Linux</title>

    <meta charset="utf-8" />
    <meta name="description" content="Download Ollama for Linux"/>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta property="og:title" content="Download Ollama on Linux" />
    <meta property="og:description" content="Download Ollama for Linux" />
    <meta property="og:url" content="https://ollama.com/download/linux" />
    <meta property="og:image" content="https://ollama.com/public/og.png" />
    <meta property="og:image:type" content="image/png" />
    <meta property="og:image:width" content="1200" />
    <meta property="og:image:height" content="628" />
    <meta property="og:type" content="website" />

    <meta property="twitter:card" content="summary" />
    <meta property="twitter:title" content="Download Ollama on Linux" />
    <meta property="twitter:description" content="Download Ollama for Linux" />
    <meta property="twitter:site" content="ollama" />

    <meta property="twitter:image:src" content="https://ollama.com/public/og-twitter.png" />
    <meta property="twitter:image:width" content="1200" />
    <meta property="twitter:image:height" content="628" />

    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">

    <link rel="icon" type="image/png" sizes="16x16" href="/public/icon-16x16.png" />
    <link rel="icon" type="image/png" sizes="32x32" href="/public/icon-32x32.png" />
    <link rel="icon" type="image/png" sizes="48x48" href="/public/icon-48x48.png" />
    <link rel="icon" type="image/png" sizes="64x64" href="/public/icon-64x64.png" />
    <link rel="apple-touch-icon" sizes="180x180" href="/public/apple-touch-icon.png" />
    <link rel="icon" type="image/png" sizes="192x192" href="/public/android-chrome-icon-192x192.png" />
    <link rel="icon" type="image/png" sizes="512x512" href="/public/android-chrome-icon-512x512.png" />

    
    

    <link href="/public/tailwind.css?v=b16c83dc54a2ba7facffb2bbcc285e55" rel="stylesheet" />
    <script type="application/ld+json">
      {
        "@context": "https://schema.org",
        "@type": "WebSite",
        "name": "Ollama",
        "url": "https://ollama.com"
      }
    </script>

    <script type="text/javascript">
      function copyToClipboard(element) {
        let commandElement = null;
        const preElement = element.closest('pre');
        const languageNoneElement = element.closest('.language-none');

        if (preElement) {
          commandElement = preElement.querySelector('code');
        } else if (languageNoneElement) {
          commandElement = languageNoneElement.querySelector('.command');
        } else {
          const parent = element.parentElement;
          if (parent) {
            commandElement = parent.querySelector('.command');
          }
        }

        if (!commandElement) {
          console.error('No code or command element found');
          return;
        }

        const code = commandElement.textContent ? commandElement.textContent.trim() : commandElement.value;

        navigator.clipboard
          .writeText(code)
          .then(() => {
            const copyIcon = element.querySelector('.copy-icon')
            const checkIcon = element.querySelector('.check-icon')

            copyIcon.classList.add('hidden')
            checkIcon.classList.remove('hidden')

            setTimeout(() => {
              copyIcon.classList.remove('hidden')
              checkIcon.classList.add('hidden')
            }, 2000)
          })
      }
    </script>
    
    <script>
      
      function getIcon(url) {
        url = url.toLowerCase();
        if (url.includes('x.com') || url.includes('twitter.com')) return 'x';
        if (url.includes('github.com')) return 'github';
        if (url.includes('linkedin.com')) return 'linkedin';
        if (url.includes('youtube.com')) return 'youtube';
        if (url.includes('hf.co') || url.includes('huggingface.co') || url.includes('huggingface.com')) return 'hugging-face';
        return 'default';
      }

      function setInputIcon(input) {
        const icon = getIcon(input.value);
        const img = input.previousElementSibling.querySelector('img');
        img.src = `/public/social/${icon}.svg`;
        img.alt = `${icon} icon`;
      }

      function setDisplayIcon(imgElement, url) {
        const icon = getIcon(url);
        imgElement.src = `/public/social/${icon}.svg`;
        imgElement.alt = `${icon} icon`;
      }
    </script>
    
    <script src="/public/vendor/htmx/bundle.js"></script>
    
  </head>

  <body
    class="
      antialiased
      min-h-screen
      w-full
      m-0
      flex
      flex-col
    "
    hx-on:keydown="
      if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') {
        // Ignore key events in input fields.
        return;
      }
      if ((event.metaKey && event.key === 'k') || event.key === '/') {
        event.preventDefault();
        const sp = htmx.find('#search') || htmx.find('#navbar-input');
        sp.focus();
      }
    "
  >
      
<header class="sticky top-0 z-40 bg-white underline-offset-4 lg:static">
  <nav class="flex w-full items-center justify-between px-6 py-3.5">
    <a href="/" class="z-50">
      <img src="/public/ollama.png" class="w-8" alt="Ollama" />
    </a>
    
    
    <div class="hidden lg:flex xl:flex-1 items-center space-x-6 ml-6 mr-6 xl:mr-0 text-lg">
      <a class="hover:underline focus:underline focus:outline-none focus:ring-0" target="_blank" href="https://discord.com/invite/ollama">Discord</a>
      <a class="hover:underline focus:underline focus:outline-none focus:ring-0" target="_blank" href="https://github.com/ollama/ollama">GitHub</a>
      <a class="hover:underline focus:underline focus:outline-none focus:ring-0" href="/models">Models</a>
    </div>

    
    <div class="flex-grow justify-center items-center hidden lg:flex xl:-ml-8">
      <div class="relative w-full xl:max-w-[28rem]">
        
<form action="/search" autocomplete="off">
  <div 
    class="relative flex w-full appearance-none bg-black/5 border border-neutral-100 items-center rounded-full"
    hx-on:focusout="
      if (!this.contains(event.relatedTarget)) {
        const searchPreview = document.querySelector('#searchpreview');
        if (searchPreview) {
          htmx.addClass('#searchpreview', 'hidden');
        }
      }
    "
  >
  <span id="searchIcon" class="pl-2 text-2xl text-neutral-500">
    <svg class="mt-0.25 ml-1.5 h-5 w-5 fill-current" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
      <path d="m8.5 3c3.0375661 0 5.5 2.46243388 5.5 5.5 0 1.24832096-.4158777 2.3995085-1.1166416 3.3225711l4.1469717 4.1470988c.2928932.2928932.2928932.767767 0 1.0606602-.2662666.2662665-.6829303.2904726-.9765418.0726181l-.0841184-.0726181-4.1470988-4.1469717c-.9230626.7007639-2.07425014 1.1166416-3.3225711 1.1166416-3.03756612 0-5.5-2.4624339-5.5-5.5 0-3.03756612 2.46243388-5.5 5.5-5.5zm0 1.5c-2.209139 0-4 1.790861-4 4s1.790861 4 4 4 4-1.790861 4-4-1.790861-4-4-4z" />
    </svg>
  </span>
  <input
    id="search"
    hx-get="/search"
    hx-trigger="keyup changed delay:100ms, focus"
    hx-target="#searchpreview"
    hx-swap="innerHTML"
    name="q"
    class="resize-none rounded-full border-0 py-2.5 bg-transparent text-sm w-full placeholder:text-neutral-500 focus:outline-none focus:ring-0"
    placeholder="Search models"
    autocomplete="off"
    hx-on:keydown="
      if (event.key === 'Enter') {
        event.preventDefault();
        window.location.href = '/search?q=' + encodeURIComponent(this.value);
        return;
      }
      if (event.key === 'Escape') {
        event.preventDefault();
        this.value = '';
        this.blur();
        htmx.addClass('#searchpreview', 'hidden');
        return;
      }
      if (event.key === 'Tab') { 
        htmx.addClass('#searchpreview', 'hidden');
        return;
      }
      if (event.key === 'ArrowDown') {
        let first = document.querySelector('#search-preview-list a:first-of-type');
        first?.focus();
        event.preventDefault();
      }
      if (event.key === 'ArrowUp') {
        let last = document.querySelector('#view-all-link');
        last?.focus();
        event.preventDefault();
      }
      htmx.removeClass('#searchpreview', 'hidden');
    "
    hx-on:focus="
      htmx.removeClass('#searchpreview', 'hidden')
    "
  />
</form>
<div id="searchpreview" class="hidden absolute left-0 right-0 top-12 z-50" style="width: calc(100% + 2px); margin-left: -1px;"></div>
</div>

      </div>
    </div>

    
    <div class="hidden lg:flex xl:flex-1 items-center space-x-2 justify-end ml-6 xl:ml-0">
      
        <a class="flex cursor-pointer items-center rounded-full bg-white border border-neutral-300 text-lg px-4 py-1 text-black hover:bg-neutral-50 whitespace-nowrap focus:bg-neutral-50" href="/signin">Sign in</a>
        <a class="flex cursor-pointer items-center rounded-full bg-neutral-800 text-lg px-4 py-1 text-white hover:bg-black whitespace-nowrap focus:bg-black" href="/download">Download</a>
      
    </div>
    
    
    <div class="lg:hidden flex items-center">
      <input type="checkbox" id="menu" class="peer hidden" />
      <label for="menu" class="z-50 cursor-pointer peer-checked:hidden block">
        <svg
          class="h-8 w-8"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          aria-hidden="true"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
          />
        </svg>
      </label>
      <label for="menu" class="z-50 cursor-pointer hidden peer-checked:block fixed top-4 right-6">
        <svg
          class="h-8 w-8"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          aria-hidden="true"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M6 18L18 6M6 6l12 12"
          />
        </svg>
      </label>
      
      <div class="fixed inset-0 bg-white z-40 hidden peer-checked:block overflow-y-auto">
        <div class="flex flex-col space-y-5 pt-[5.5rem] text-3xl">
          
          <a class="px-6" href="/models">Models</a>
          <a class="px-6" href="https://discord.com/invite/ollama">Discord</a>
          <a class="px-6" href="https://github.com/ollama/ollama">GitHub</a>

          

          
          <a class="px-6" href="/download">Download</a>
          <a href="/signin" class="block px-6">Sign in</a>
          

          
        </div>
      </div>
    </div>
  </nav>
</header>


    <main class="flex-grow">
      
  <main class="mx-auto flex max-w-6xl flex-1 flex-col items-center px-6 py-24">
    <h1 class="mb-12 text-3xl tracking-tight">Download Ollama</h1>
    <nav class="grid grid-cols-3 gap-4 text-sm">
      <a
        href="/download/mac"
        class="
          flex cursor-pointer flex-col items-center rounded-lg px-6 py-2 hover:bg-neutral-100
        "
      >
        <svg
          fill="currentColor"
          stroke-width="0"
          viewBox="0 0 1024 1024"
          class="h-8 w-8 p-1"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M747.4 535.7c-.4-68.2 30.5-119.6 92.9-157.5-34.9-50-87.7-77.5-157.3-82.8-65.9-5.2-138 38.4-164.4 38.4-27.9 0-91.7-36.6-141.9-36.6C273.1 298.8 163 379.8 163 544.6c0 48.7 8.9 99 26.7 150.8 23.8 68.2 109.6 235.3 199.1 232.6 46.8-1.1 79.9-33.2 140.8-33.2 59.1 0 89.7 33.2 141.9 33.2 90.3-1.3 167.9-153.2 190.5-221.6-121.1-57.1-114.6-167.2-114.6-170.7zm-105.1-305c50.7-60.2 46.1-115 44.6-134.7-44.8 2.6-96.6 30.5-126.1 64.8-32.5 36.8-51.6 82.3-47.5 133.6 48.4 3.7 92.6-21.2 129-63.7z"
          ></path>
        </svg>
        macOS
      </a>
      <a
        href="/download/linux"
        class="
          bg-neutral-100 flex cursor-pointer flex-col items-center rounded-lg px-6 py-2 hover:bg-neutral-100"
      >
        <svg
          stroke="currentColor"
          fill="currentColor"
          stroke-width="0"
          viewBox="0 0 448 512"
          class="h-8 w-8 p-0.5"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M220.8 123.3c1 .5 1.8 1.7 3 1.7 1.1 0 2.8-.4 2.9-1.5.2-1.4-1.9-2.3-3.2-2.9-1.7-.7-3.9-1-5.5-.1-.4.2-.8.7-.6 1.1.3 1.3 2.3 1.1 3.4 1.7zm-21.9 1.7c1.2 0 2-1.2 3-1.7 1.1-.6 3.1-.4 3.5-1.6.2-.4-.2-.9-.6-1.1-1.6-.9-3.8-.6-5.5.1-1.3.6-3.4 1.5-3.2 2.9.1 1 1.8 1.5 2.8 1.4zM420 403.8c-3.6-4-5.3-11.6-7.2-19.7-1.8-8.1-3.9-16.8-10.5-22.4-1.3-1.1-2.6-2.1-4-2.9-1.3-.8-2.7-1.5-4.1-2 9.2-27.3 5.6-54.5-3.7-79.1-11.4-30.1-31.3-56.4-46.5-74.4-17.1-21.5-33.7-41.9-33.4-72C311.1 85.4 315.7.1 234.8 0 132.4-.2 158 103.4 156.9 135.2c-1.7 23.4-6.4 41.8-22.5 64.7-18.9 22.5-45.5 58.8-58.1 96.7-6 17.9-8.8 36.1-6.2 53.3-6.5 5.8-11.4 14.7-16.6 20.2-4.2 4.3-10.3 5.9-17 8.3s-14 6-18.5 14.5c-2.1 3.9-2.8 8.1-2.8 12.4 0 3.9.6 7.9 1.2 11.8 1.2 8.1 2.5 15.7.8 20.8-5.2 14.4-5.9 24.4-2.2 31.7 3.8 7.3 11.4 10.5 20.1 12.3 17.3 3.6 40.8 2.7 59.3 12.5 19.8 10.4 39.9 14.1 55.9 10.4 11.6-2.6 21.1-9.6 25.9-20.2 12.5-.1 26.3-5.4 48.3-6.6 14.9-1.2 33.6 5.3 55.1 4.1.6 2.3 1.4 4.6 2.5 6.7v.1c8.3 16.7 23.8 24.3 40.3 23 16.6-1.3 34.1-11 48.3-27.9 13.6-16.4 36-23.2 50.9-32.2 7.4-4.5 13.4-10.1 13.9-18.3.4-8.2-4.4-17.3-15.5-29.7zM223.7 87.3c9.8-22.2 34.2-21.8 44-.4 6.5 14.2 3.6 30.9-4.3 40.4-1.6-.8-5.9-2.6-12.6-4.9 1.1-1.2 3.1-2.7 3.9-4.6 4.8-11.8-.2-27-9.1-27.3-7.3-.5-13.9 10.8-11.8 23-4.1-2-9.4-3.5-13-4.4-1-6.9-.3-14.6 2.9-21.8zM183 75.8c10.1 0 20.8 14.2 19.1 33.5-3.5 1-7.1 2.5-10.2 4.6 1.2-8.9-3.3-20.1-9.6-19.6-8.4.7-9.8 21.2-1.8 28.1 1 .8 1.9-.2-5.9 5.5-15.6-14.6-10.5-52.1 8.4-52.1zm-13.6 60.7c6.2-4.6 13.6-10 14.1-10.5 4.7-4.4 13.5-14.2 27.9-14.2 7.1 0 15.6 2.3 25.9 8.9 6.3 4.1 11.3 4.4 22.6 9.3 8.4 3.5 13.7 9.7 10.5 18.2-2.6 7.1-11 14.4-22.7 18.1-11.1 3.6-19.8 16-38.2 14.9-3.9-.2-7-1-9.6-2.1-8-3.5-12.2-10.4-20-15-8.6-4.8-13.2-10.4-14.7-15.3-1.4-4.9 0-9 4.2-12.3zm3.3 334c-2.7 35.1-43.9 34.4-75.3 18-29.9-15.8-68.6-6.5-76.5-21.9-2.4-4.7-2.4-12.7 2.6-26.4v-.2c2.4-7.6.6-16-.6-23.9-1.2-7.8-1.8-15 .9-20 3.5-6.7 8.5-9.1 14.8-11.3 10.3-3.7 11.8-3.4 19.6-9.9 5.5-5.7 9.5-12.9 14.3-18 5.1-5.5 10-8.1 17.7-6.9 8.1 1.2 15.1 6.8 21.9 16l19.6 35.6c9.5 19.9 43.1 48.4 41 68.9zm-1.4-25.9c-4.1-6.6-9.6-13.6-14.4-19.6 7.1 0 14.2-2.2 16.7-8.9 2.3-6.2 0-14.9-7.4-24.9-13.5-18.2-38.3-32.5-38.3-32.5-13.5-8.4-21.1-18.7-24.6-29.9s-3-23.3-.3-35.2c5.2-22.9 18.6-45.2 27.2-59.2 2.3-1.7.8 3.2-8.7 20.8-8.5 16.1-24.4 53.3-2.6 82.4.6-20.7 5.5-41.8 13.8-61.5 12-27.4 37.3-74.9 39.3-112.7 1.1.8 4.6 3.2 6.2 4.1 4.6 2.7 8.1 6.7 12.6 10.3 12.4 10 28.5 9.2 42.4 1.2 6.2-3.5 11.2-7.5 15.9-9 9.9-3.1 17.8-8.6 22.3-15 7.7 30.4 25.7 74.3 37.2 95.7 6.1 11.4 18.3 35.5 23.6 64.6 3.3-.1 7 .4 10.9 1.4 13.8-35.7-11.7-74.2-23.3-84.9-4.7-4.6-4.9-6.6-2.6-6.5 12.6 11.2 29.2 33.7 35.2 59 2.8 11.6 3.3 23.7.4 35.7 16.4 6.8 35.9 17.9 30.7 34.8-2.2-.1-3.2 0-4.2 0 3.2-10.1-3.9-17.6-22.8-26.1-19.6-8.6-36-8.6-38.3 12.5-12.1 4.2-18.3 14.7-21.4 27.3-2.8 11.2-3.6 24.7-4.4 39.9-.5 7.7-3.6 18-6.8 29-32.1 22.9-76.7 32.9-114.3 7.2zm257.4-11.5c-.9 16.8-41.2 19.9-63.2 46.5-13.2 15.7-29.4 24.4-43.6 25.5s-26.5-4.8-33.7-19.3c-4.7-11.1-2.4-23.1 1.1-36.3 3.7-14.2 9.2-28.8 9.9-40.6.8-15.2 1.7-28.5 4.2-38.7 2.6-10.3 6.6-17.2 13.7-21.1.3-.2.7-.3 1-.5.8 13.2 7.3 26.6 18.8 29.5 12.6 3.3 30.7-7.5 38.4-16.3 9-.3 15.7-.9 22.6 5.1 9.9 8.5 7.1 30.3 17.1 41.6 10.6 11.6 14 19.5 13.7 24.6zM173.3 148.7c2 1.9 4.7 4.5 8 7.1 6.6 5.2 15.8 10.6 27.3 10.6 11.6 0 22.5-5.9 31.8-10.8 4.9-2.6 10.9-7 14.8-10.4s5.9-6.3 3.1-6.6-2.6 2.6-6 5.1c-4.4 3.2-9.7 7.4-13.9 9.8-7.4 4.2-19.5 10.2-29.9 10.2s-18.7-4.8-24.9-9.7c-3.1-2.5-5.7-5-7.7-6.9-1.5-1.4-1.9-4.6-4.3-4.9-1.4-.1-1.8 3.7 1.7 6.5z"
          ></path>
        </svg>
        Linux
      </a>
      <a
        href="/download/windows"
        class="
          flex cursor-pointer flex-col items-center rounded-lg px-6 py-2 hover:bg-neutral-100
        "
      >
        <svg
          fill="currentColor"
          stroke-width="0"
          viewBox="0 0 448 512"
          class="b h-8 w-8 p-1"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            d="M0 93.7l183.6-25.3v177.4H0V93.7zm0 324.6l183.6 25.3V268.4H0v149.9zm203.8 28L448 480V268.4H203.8v177.9zm0-380.6v180.1H448V32L203.8 65.7z"
          ></path>
        </svg>
        Windows
      </a>
    </nav>
    
      
  <div class="mx-auto mb-16 mt-12 flex w-full flex-col items-center text-center self-center">
    <h2 class="mb-4 text-lg">Install with one command:</h2>
    <div class="min-w-0 max-w-full flex-1 self-center text-right">
      <pre
        class="language-none mb-2 flex justify-center whitespace-nowrap rounded-lg bg-neutral-100 font-mono text-sm"
      >
      <code class="command min-w-0 py-3 pl-4 pr-4 overflow-auto">curl -fsSL https://ollama.com/install.sh | sh</code>
      <button
        class="block cursor-pointer py-1 px-3 leading-none text-neutral-500 hover:text-black focus:outline-none"
        onclick="copyToClipboard(this)"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="copy-icon h-5 w-5"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M16.5 8.25V6a2.25 2.25 0 00-2.25-2.25H6A2.25 2.25 0 003.75 6v8.25A2.25 2.25 0 006 16.5h2.25m8.25-8.25H18a2.25 2.25 0 012.25 2.25V18A2.25 2.25 0 0118 20.25h-7.5A2.25 2.25 0 018.25 18v-1.5m8.25-8.25h-6a2.25 2.25 0 00-2.25 2.25v6"
          />
          </svg>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="check-icon hidden h-5 w-5"
          >
          <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
        </svg>
      </button>
      </pre>
      <div class="flex justify-center text-xs space-x-1 text-neutral-800 underline-offset-4">
        <a
          class="hover:underline focus:underline focus:outline-none focus:ring-0"
          href="https://github.com/ollama/ollama/blob/main/scripts/install.sh"
          target="_blank"
        >
          View script source
        </a>
        •
        <a
          class="hover:underline focus:underline focus:outline-none focus:ring-0"
          href="https://github.com/ollama/ollama/blob/main/docs/linux.md"
          target="_blank"
        >
          Manual install instructions
        </a>
      </div>
    </div>
  </div>

    
    <hr class="w-full sm:max-w-md" />
    <form
      class="mx-auto flex w-full min-w-0 max-w-[18rem] flex-col items-center space-y-3 text-center"
      hx-post="/newsletter/signup"
      hx-swap="none"
      hx-target="this"
      hx-on::after-request="this.reset()"
    >
      <h3 class="mt-12 text-sm text-neutral-800">
        While Ollama downloads, sign up to get notified of new updates.
      </h3>
      <input
        required
        type="email"
        name="email"
        placeholder="your email address"
        class="px-4 py-3 w-full rounded-xl text-sm placeholder:text-sm placeholder:text-neutral-400 border-neutral-300 focus:ring focus:ring-opacity-75 focus:border-blue-400 focus:ring-blue-300"
      />
      <input
        type="submit"
        value="Get updates"
        class="w-full cursor-pointer rounded-3xl bg-white border p-2 border-neutral-300 hover:bg-neutral-50 whitespace-nowrap focus:outline-none focus:ring-0 disabled:opacity-50"
        hx-disable-element="this"
      />
      <div error class="text-xs text-red-500 empty:hidden"></div>
      <div success class="text-xs text-green-500 empty:hidden"></div>
    </form>
  </main>

    </main>

    
<footer class="mt-auto">
  <div class="bg-white underline-offset-4 hidden md:block">
    <div class="flex items-center justify-between px-6 py-3.5">
      <div class="text-xs text-neutral-500">© 2025 Ollama</div>
      <div class="flex space-x-6 text-xs text-neutral-500">
        <a href="/blog" class="hover:underline">Blog</a>
        <a href="https://github.com/ollama/ollama/tree/main/docs" class="hover:underline">Docs</a>
        <a href="https://github.com/ollama/ollama" class="hover:underline">GitHub</a>
        <a href="https://discord.com/invite/ollama" class="hover:underline">Discord</a>
        <a href="https://twitter.com/ollama" class="hover:underline">X (Twitter)</a>
        <a href="https://lu.ma/ollama" class="hover:underline">Meetups</a>
        <a href="/download" class="hover:underline">Download</a>
      </div>
    </div>
  </div>
  <div class="bg-white py-4 md:hidden">
    <div class="flex flex-col items-center justify-center">
      <ul class="flex flex-wrap items-center justify-center text-sm text-neutral-500">
        <li class="mx-2 my-1">
          <a href="/blog" class="hover:underline">Blog</a>
        </li>
        <li class="mx-2 my-1">
          <a href="/download" class="hover:underline">Download</a>
        </li>
        <li class="mx-2 my-1">
          <a href="https://github.com/ollama/ollama/tree/main/docs" class="hover:underline">Docs</a>
        </li>
      </ul>
      <ul class="flex flex-wrap items-center justify-center text-sm text-neutral-500">
        <li class="mx-2 my-1">
          <a href="https://github.com/ollama/ollama" class="hover:underline">GitHub</a>
        </li>
        <li class="mx-2 my-1">
          <a href="https://discord.com/invite/ollama" class="hover:underline">Discord</a>
        </li>
        <li class="mx-2 my-1">
          <a href="https://twitter.com/ollama" class="hover:underline">X (Twitter)</a>
        </li>
        <li class="mx-2 my-1">
          <a href="https://lu.ma/ollama" class="hover:underline">Meetups</a>
        </li>
      </ul>
      <div class="mt-2 flex items-center justify-center text-sm text-neutral-500">
        © 2025 Ollama Inc.
      </div>
    </div>
  </div>
</footer>


    
    <span class="hidden" id="end_of_template"></span>
  </body>
</html>
