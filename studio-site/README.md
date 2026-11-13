# AF GAMER CI — site officiel

Site vitrine statique indépendant du jeu RAFORI FANTASY. Il est conçu pour être publié gratuitement sur **Cloudflare Pages**.

## Contenu
- Présentation du studio AF GAMER CI et du jeu RAFORI FANTASY.
- Codex de l'univers, peuples, héros, monstres, quêtes et vision du jeu.
- Guide de démarrage et liens vers le build de test.
- Présentation de la conception future des comptes, sauvegardes cloud, équipes et butin partagé.
- Navigation mobile, prise en charge clavier, balises de référencement et page 404.

## Déployer gratuitement sur Cloudflare Pages

Aucun achat de domaine n'est nécessaire. Cloudflare fournit une adresse gratuite en `pages.dev`.

1. Créer ou ouvrir un compte sur [Cloudflare](https://dash.cloudflare.com/sign-up).
2. Ouvrir **Workers & Pages** puis choisir **Create application** > **Pages** > **Connect to Git**.
3. Autoriser l'accès au dépôt public `yaminoxcode-eng/RAFORI_fantasy`.
4. Choisir le dépôt `RAFORI_fantasy`.
5. Dans les paramètres de build :
   - **Production branch** : `af-gamer-studio-site`
   - **Framework preset** : `None`
   - **Build command** : laisser vide
   - **Build output directory** : `studio-site`
   - **Root directory** : laisser la valeur par défaut (racine du dépôt)
6. Lancer **Save and Deploy**. Cloudflare publiera le contenu de `studio-site/` et affichera une adresse du type `https://nom-du-projet.pages.dev`.
7. Ouvrir l'adresse fournie, tester les liens et le menu mobile, puis partager cette adresse.

À chaque nouveau commit poussé sur `af-gamer-studio-site`, Cloudflare Pages reconstruira automatiquement le site. Les aperçus de branches peuvent aussi être activés dans les paramètres du projet.

## Nom de domaine personnalisé (facultatif)

Le domaine `af-gamer-ci.com` n'est pas inclus dans l'hébergement gratuit : il faut l'acheter auprès d'un registraire et renouveler son paiement. Pour commencer sans frais, conserver l'adresse `.pages.dev`. Plus tard, ajouter le domaine dans **Custom domains** dans Cloudflare Pages et suivre les instructions DNS affichées.

## Sécurité et limites actuelles

- Les formulaires de création de compte et de connexion sont des maquettes : ils n'envoient ni ne stockent les identifiants.
- Aucun service Supabase n'est encore connecté ; la migration SQL est une base de travail à appliquer uniquement après création et vérification d'un projet dédié.
- Les sauvegardes cloud, comptes, équipes, butin partagé et multijoueur ne sont pas opérationnels.
- Le site vitrine peut être hébergé gratuitement ; un futur serveur de jeu persistant, SMS OTP, base de données au-delà des quotas gratuits ou domaine personnalisé peuvent générer des frais.
- Ne jamais demander aux visiteurs de saisir un vrai mot de passe tant que l'authentification sécurisée n'est pas branchée.

## Test local

Ouvrir directement `index.html` dans un navigateur moderne. Aucun build ni dépendance n'est requis.
