#cloud-config
package_update: true
package_upgrade: true
packages:
  - nginx
write_files:
  - path: /var/www/html/index.html
    content: ${index_html}
    encoding: b64
  - path: /var/www/html/style.css
    content: ${style_css}
    encoding: b64
  - path: /var/www/html/script.js
    content: ${script_js}
    encoding: b64
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
