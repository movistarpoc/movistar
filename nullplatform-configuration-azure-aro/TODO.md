- Especificar bien qué cosas van a ir a nivel account y cuáles a nivel org
- Hacer que cree automaticamente el container del state
- Agregar creación de account de nullplatform
- crear dns privado con tofu
- Resolver el problema de tener que clonar a mano el repo de scopes en .terraform-repo
- Discutir si es necesario bajarse TODO el codigo de los repos para aplicar el JSON de la definicion del scope

- Ver si el helmchart base no deberian tener un depends on del helmchart del certificado

Bug que nos demoro mucho al aplicar y lo resolvimos con claude code:

- Tuvimos que agregar a los modulos:
  - helm chart base: config del ingress q estbaa hardcodada en false
  - helm chart cert manager: que use los DNS de google / cloudflare para vlidar los records TXT porque no podia hacerlo desde afuera
  - ahora hay que hacer releases de esos fixes y probarlo
  
- Copia del certificado
  - Claude code copio a mano el certificado TLS del namespace "openshift-ingress-operator" => "openshift-ingress", este paso manual hay que resolverlo
  - aparentemente se puede configurar el modulo para decirle ewrqwrwqdonde tiene q dejar el secret y no hace falta lo anterior