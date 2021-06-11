# Features

## Blogs and pages
- 1 Click Blogging posts directly from browser.
- 1 Click Static web pages directly from browser.
- WYSIWYG & Drag'n'Drop Editors with [Summernote](https://summernote.org), [CodeMirror](https://codemirror.net) or [GrapesJS](https://grapesjs.com).
- Custom title, meta description and keywords for each page, SEO friendly.
- Custom head, navbar and footer, no hardcoded watermarks, links or logos.
- Upload/Download files and images (private or public), option to use MD5 CheckSum as filename.
- [Libravatar/Gravatar support](https://wiki.libravatar.org/libraries/#index2h1) for profile photos builtin.
- 1 language for the whole stack, including high performance modules, scripting, devops, deploy, from WebAssembly to Assembly.

## Security
- Self-Firejailing Web Framework (It Firejails itself) Best Linux Security integrated on the Core.
- 2 Factor Athentication TOTP
- [Design by Contract, Contract Programming](https://dev.to/juancarlospaco/design-by-contract-immutability-side-effects-and-gulag-44fk).
- Security Hardened by default (based from [Gentoo Hardened](https://wiki.gentoo.org/wiki/Hardened_Gentoo) and [Debian Hardened](https://wiki.debian.org/Hardening), checked with [`hardening-check`](https://bitbucket.org/Alexander-Shukaev/hardening-check)).
- Coded following the [Power of 10: NASA Coding guidelines for safety-critical code](https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code#Rules) (as much as possible).
- ReCAPTCHA (Optional)
- [HoneyPot-Field](https://stackoverflow.com/questions/36227376/better-honeypot-implementation-form-anti-spam/36227377)
- BCrypt+Salt password hashing
- No user Tracking Analytics by default
- SQL Type-checked and Query-checked at compile-time, no SQL injections.
- No XML nor YAML nor ZIP used on the Core, No XML Vulnerabilities, No YAML Vulnerabilities, etc (you can still use XML and YAML and ZIP).
- Multiple users with different ranks, role based access control.
- Admin can choose how much CPU & RAM NimWC can use from the Admin Dashboard (using the compile flag `-d:firejail`)
- We recommend [FreeOTP 2 Factor Athentication App](https://freeotp.github.io) because is Open Source (400Kb size),
As alternative, [try AndOTP](https://github.com/andOTP/andOTP) (5Mb size).

## Configuration
- Edit core or custom JS and CSS directly from browser, UI/UX Designer friendly.
- Log Viewer directly from browser.
- Auto-Rotating file Logger.
- Server Info Page for Admins.
- Force Server restart for Admins.
- Edit main config file directly from browser
- Recompilation without down times.
- Webserver hosting your page on 127.0.0.1:7000
- Colored output on the Terminal.
- Email notification on critical errors.

## Plugins
- Plugin Store integrated
- Enable and disable plugins directly from browser. Open Source or Private Plugins.
- Plugin skeleton creator to create your own new plugins.
- Plugins can do anything you want on Frontend and Backend.
- Develop your own plugins - [NimWC plugin repository](https://github.com/ThomasTJdev/nimwc_plugins)

## Database
- [Postgres](https://www.postgresql.org) (if you are using the NimWC docker file, you do not need to install Postgres)
- SQLite

## Performance
- High performance with low resources (RPi, VPS, cloud, old pc, etc).
- Runs on any non-Windows OS, Architecture and Hardware that can compile C code.
- Independent [TechEmpower Benchmarks](https://www.techempower.com/benchmarks/#section=data-r17&hw=cl&test=json) show Nim web server as one of the fastest in the world.
- High Availability design by default.
- Full Stack with the same programming language, including DevOps and Scripting.
- 0 Dependency binary (Postgres/SSL/WebP/Firejail required if using it).
- No `/node_modules/`, but very powerful builtin Templating engine.
- Compile-Time precomputed arbitrary function execution is used when possible.
- No Global Interpreter Lock, no single-Thread, no single-Core, no Interpreter. Use all your 32 CPU Cores.

## Responsive
- Uses responsive [Bulma CSS framework](https://bulma.io), supports [Bootstrap CSS framework](https://getbootstrap.com).
- JavaScript framework agnostic, use Nim, [Karax](https://github.com/pragmagic/karax), vanilla JS, you choose.

## Other
- [WebP](https://caniuse.com/#feat=webp) automatic Image and Photo Optimizations.
- [NGINX Config](https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/) template.
- [SystemD Service](https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/) template.
- [Vagrantfile](https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/) template.
- [Dockerfile](https://github.com/ThomasTJdev/nim_websitecreator/tree/master/devops/docker/) template.
