Um app de notificação de serviço, no qual envia localização atual do usuário, ou um outro endereço especificado pelo mesmo, para o motorista. Uma marca de localização também é colocada no mapa com um raio de distância. Todas essas marcas que são disponibilizadas pelos usuários, ficam visíveis ao motorista que tem um app específico com acesso a esses dados e organizados do mais próximo ao mais distante.

Esse aplicativo, é uma réplica de um app android nativo interno feito para uma empresa. O intuito era recriar o app com a mesma funcionalidade usando flutter para fins de aprendizado e conhecimento. Então o mesmo ainda não possui uma arquitetura e estrutura robusto,  dependendo dos resultados isso será definido futuramente.

Tecnologias e dependências usadas no projeto: Firebase para o back-end tanto no armazenamento de dados quanto na autenticação do usuário; Animated text; Google maps; Geolocator; Permission Handler; Cloud firestore; firebase auth e core.

Obs: Caso for usar o app, não esqueça de adicioná-lo ao seu projeto do firebase, para poder baixar o google-services.json android e/ou GoogleService-Info.plist ios com sua API_KEY.


