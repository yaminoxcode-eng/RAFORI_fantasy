# AF GAMER CI — site studio

Site vitrine indépendant du jeu RAFORI FANTASY. Cette version est une première base statique responsive, destinée à être publiée séparément du jeu.

## Contenu
- Accueil studio, catalogue extensible, documentation RAFORI, guide de démarrage.
- Accès au build de test RAFORI actuellement publié.
- Présentation de la conception cible des comptes, équipes, chasse coopérative et butin partagé.
- Formulaires d'inscription/connexion volontairement non connectés : ils n'enregistrent et ne transmettent aucune donnée.

## Déploiement
Projet Vercel à créer avec le répertoire racine `studio-site` et le framework `Other` / site statique. Le dossier ne doit pas remplacer l'index.html du jeu.

## À intégrer avant ouverture publique des comptes
1. Base de données et authentification (hash de mot de passe côté serveur, limitation de tentatives, vérification du téléphone par OTP).
2. API de profil et sauvegardes versionnées, contrôles d'accès et journalisation.
3. Serveur de jeu autoritaire temps réel (WebSocket), matchmaking/instances, validation des déplacements et combats.
4. Calcul de puissance des monstres en fonction de l'effectif; attribution du butin côté serveur, idempotente et anti-duplication.
5. Répartition des points d'apparition dans plusieurs zones de départ sûres; attribution d'une épée initiale dans l'inventaire de chaque nouveau personnage.
6. Tests de charge, sécurité, sauvegarde/restauration et conformité aux règles de protection des données applicables.

## Domaines
Les noms avec underscore ne sont pas valides en DNS. `af-gamer-ci.com` et `afgamerci.com` étaient disponibles lors de la vérification du 13 novembre 2026; l'enregistrement n'est pas effectué.