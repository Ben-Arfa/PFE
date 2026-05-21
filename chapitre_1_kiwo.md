# Chapitre 1 : Étude préalable et spécification des besoins

## 1.1 Introduction

Ce chapitre présente l’étude préalable du projet KIWO, une application mobile destinée à la gestion et au suivi d’un élevage avicole connecté. Il a pour objectif de situer le projet dans son contexte général, d’analyser les solutions existantes, d’identifier leurs limites et de définir les objectifs à atteindre.

La spécification des besoins constitue une étape essentielle dans la réalisation d’une application informatique. Elle permet de comprendre les attentes des utilisateurs, de préciser les fonctionnalités à développer et de fixer les contraintes de qualité que le système doit respecter. Dans ce cadre, ce chapitre présente également les principaux acteurs de l’application, les besoins fonctionnels ainsi que les besoins non fonctionnels nécessaires au bon fonctionnement de KIWO.

## 1.2 Cadre du projet

Le secteur avicole occupe une place importante dans la production alimentaire. Cependant, la gestion quotidienne d’un élevage reste souvent complexe, car elle nécessite le suivi simultané de plusieurs éléments : les bâtiments, les lots de volailles, les types de volailles, la mortalité, l’alimentation, l’eau, la production d’œufs, les vaccinations, les historiques et les conditions environnementales.

Dans plusieurs exploitations, ces informations sont encore enregistrées manuellement ou réparties entre différents supports numériques. Cette organisation peut entraîner des pertes de données, des erreurs de saisie, un manque de visibilité sur l’état réel de l’élevage et des difficultés lors de la prise de décision.

Le projet KIWO s’inscrit dans ce contexte. Il consiste à concevoir et développer une application mobile permettant de centraliser la gestion d’un élevage avicole. L’application facilite le suivi des bâtiments, la gestion des lots, la saisie quotidienne des données d’élevage, la planification des vaccinations, la consultation de l’historique et l’exploitation des données issues d’appareils IoT, notamment des capteurs de température et d’humidité basés sur ESP32.

KIWO repose sur une architecture moderne utilisant Flutter pour le développement mobile, Firebase Authentication pour la gestion des accès et Cloud Firestore pour le stockage des données en temps réel. Cette solution vise à offrir aux éleveurs un outil simple, fiable et adapté aux besoins pratiques du terrain.

## 1.3 Étude de l’existant

Avant de définir les besoins de KIWO, il est nécessaire d’étudier quelques solutions existantes dans le domaine de la gestion agricole ou avicole. Cette analyse permet de comprendre les fonctionnalités généralement proposées par ces outils, mais aussi d’identifier les limites qui justifient la mise en place d’une solution plus adaptée.

### 1.3.1 Description de l’existant

Plusieurs applications et plateformes numériques proposent aujourd’hui des services de gestion d’élevage ou de suivi agricole.

**Farmbrite** est une plateforme de gestion agricole qui permet de suivre les animaux, les ressources, les activités et les informations liées à une exploitation. Elle propose des fonctions de gestion du bétail, d’importation de données et d’organisation des informations de ferme.

**CoopSense** est une solution orientée vers la gestion avicole. Elle permet de suivre les lots, la production d’œufs, l’alimentation, la santé, les coûts et les performances de la ferme à travers un tableau de bord centralisé.

**PoultryCare** est un logiciel ERP destiné aux entreprises avicoles. Il couvre plusieurs aspects de la filière, comme la gestion des reproducteurs, des poulets de chair, des pondeuses, des couvoirs, de l’alimentation et du traitement industriel.

**Broilr** est une solution spécialisée dans la gestion des élevages de poulets de chair. Elle met l’accent sur les indicateurs de performance, les coûts de production, la rentabilité des lots et le suivi financier des opérations avicoles.

Ces solutions montrent l’importance croissante de la numérisation dans le domaine agricole. Elles permettent d’améliorer l’organisation des données, de suivre les performances et d’aider les responsables d’élevage dans leurs décisions.

### 1.3.2 Critique de l’existant

Malgré leur utilité, les solutions existantes présentent certaines limites lorsqu’elles sont comparées aux besoins spécifiques d’un élevage avicole local ou de taille moyenne.

Tout d’abord, plusieurs plateformes sont conçues comme des solutions complètes de type ERP. Elles sont souvent riches en fonctionnalités, mais peuvent être complexes à utiliser pour un éleveur qui souhaite simplement suivre ses bâtiments, ses lots, ses saisies quotidiennes et ses vaccinations.

Ensuite, certaines applications ciblent des exploitations de grande taille ou des structures industrielles. Elles peuvent donc être moins adaptées aux petites et moyennes exploitations qui ont besoin d’une interface plus simple, plus directe et centrée sur les opérations quotidiennes.

De plus, l’intégration des objets connectés n’est pas toujours mise au centre de l’expérience utilisateur. Or, dans un élevage avicole, les données environnementales comme la température et l’humidité sont essentielles pour détecter rapidement les anomalies et préserver la santé des volailles.

Enfin, certaines solutions ne répondent pas toujours aux contraintes locales : coût d’utilisation, disponibilité hors contexte industriel, adaptation aux méthodes de travail de l’éleveur, simplicité d’accès, langue de l’interface ou niveau de personnalisation des données suivies.

Ces limites montrent la nécessité de proposer une application mobile plus ciblée, simple à utiliser et adaptée au suivi quotidien d’un élevage avicole connecté.

### 1.3.3 Objectifs à atteindre

Face aux limites des solutions existantes, KIWO vise à proposer une application mobile claire, pratique et adaptée à la gestion avicole. Les principaux objectifs du projet sont les suivants :

- Centraliser les informations de l’élevage dans une seule application.
- Faciliter la gestion des types de volailles, des bâtiments et des lots.
- Automatiser et structurer la saisie quotidienne des données d’élevage.
- Améliorer le suivi sanitaire grâce à la planification et à la validation des vaccinations.
- Assurer la traçabilité des lots depuis leur création jusqu’à leur clôture.
- Exploiter les données IoT pour surveiller les conditions environnementales.
- Offrir un tableau de bord permettant de visualiser rapidement l’état général de l’élevage.
- Renforcer la sécurité des données grâce à l’authentification et aux règles d’accès.

Ainsi, KIWO cherche à accompagner l’éleveur dans son travail quotidien en réduisant les oublis, en améliorant la qualité du suivi et en facilitant la prise de décision.

## 1.4 Spécification des besoins

La spécification des besoins permet de définir précisément ce que l’application doit offrir à ses utilisateurs. Elle distingue les acteurs qui interagissent avec le système, les besoins fonctionnels qui décrivent les services attendus, et les besoins non fonctionnels qui définissent les contraintes de qualité.

### 1.4.1 Identification des acteurs

Les principaux acteurs de l’application KIWO sont les suivants :

**Administrateur** : il dispose d’un accès privilégié à l’application. Son rôle consiste à gérer les comptes utilisateurs, consulter la liste des utilisateurs, créer de nouveaux comptes, modifier les rôles, envoyer des réinitialisations de mot de passe et supprimer des comptes si nécessaire. Il garantit ainsi l’organisation et le contrôle des accès au système.

**Éleveur ou utilisateur** : il représente l’acteur principal de l’application. Il utilise KIWO pour gérer son élevage avicole au quotidien. Il peut créer des types de volailles, gérer les bâtiments, créer et clôturer les lots, enregistrer les données journalières, planifier les vaccinations, consulter les historiques, suivre les alertes et visualiser les informations du tableau de bord.

**Système Firebase** : il assure les services techniques nécessaires au fonctionnement de l’application. Il prend en charge l’authentification des utilisateurs, le stockage des données dans Cloud Firestore, la synchronisation des informations et l’application des règles de sécurité selon le rôle et l’identité de l’utilisateur.

**Appareils IoT et capteurs ESP32** : ils interviennent comme sources de données environnementales. Ils permettent de collecter des mesures telles que la température et l’humidité afin d’aider l’éleveur à surveiller l’état des bâtiments et à réagir rapidement en cas d’anomalie.

### 1.4.2 Les besoins fonctionnels

L’application KIWO a été conçue pour simplifier la gestion d’un élevage avicole en regroupant les fonctionnalités essentielles dans une interface mobile unique. Les besoins fonctionnels identifiés sont les suivants :

**1. Authentification et gestion sécurisée des accès**

KIWO doit permettre aux utilisateurs de se connecter de manière sécurisée à l’aide d’un email et d’un mot de passe. L’application doit également proposer une fonctionnalité de réinitialisation du mot de passe en cas d’oubli.

Après l’authentification, le système doit identifier le rôle de l’utilisateur afin de le rediriger vers l’espace approprié. Un administrateur accède au tableau de bord d’administration, tandis qu’un utilisateur standard accède à l’espace de gestion de son élevage.

**2. Gestion des utilisateurs**

L’administrateur doit pouvoir gérer les comptes des utilisateurs. Cette gestion comprend la création d’un nouvel utilisateur, la consultation de la liste des comptes existants, la modification du rôle d’un utilisateur, l’envoi d’un email de réinitialisation de mot de passe et la suppression d’un compte.

Cette fonctionnalité permet de contrôler les accès à l’application et de garantir que chaque utilisateur dispose uniquement des droits correspondant à son rôle.

**3. Gestion du profil utilisateur**

Chaque utilisateur doit pouvoir consulter et modifier ses informations personnelles. KIWO doit permettre la mise à jour du profil, le changement du mot de passe, le changement de l’adresse email et la déconnexion.

Cette fonctionnalité améliore l’autonomie de l’utilisateur et lui permet de maintenir ses informations à jour sans intervention de l’administrateur.

**4. Gestion des types de volailles**

L’application doit permettre à l’éleveur de créer et gérer les types de volailles présents dans son exploitation. Chaque type peut contenir des informations techniques telles que la catégorie, la température recommandée, l’humidité recommandée, la densité, la durée typique d’élevage, le poids cible ou l’âge de début de ponte.

Cette fonctionnalité permet d’adapter le suivi aux caractéristiques propres à chaque catégorie de volaille, notamment les poulets de chair et les pondeuses.

**5. Gestion des bâtiments**

KIWO doit permettre la création, la modification et la consultation des bâtiments d’élevage. Pour chaque bâtiment, l’utilisateur peut indiquer le nom, la surface, la capacité maximale et le statut, par exemple actif, vide ou en désinfection.

La gestion des bâtiments permet à l’éleveur d’organiser son exploitation et de savoir rapidement quels espaces sont disponibles, occupés ou en phase de nettoyage.

**6. Gestion des lots de volailles**

L’application doit permettre de créer des lots de volailles en les associant à un bâtiment et à un type de volaille. Chaque lot contient des informations importantes comme l’identifiant, la date d’entrée, l’effectif initial, l’effectif actuel et la provenance.

KIWO doit également permettre de clôturer un lot à la fin du cycle d’élevage. La clôture peut inclure le nombre de sujets sortis, le poids moyen final, la production totale d’œufs et la raison de clôture. Cette fonctionnalité permet d’assurer un suivi complet du cycle de vie d’un lot.

**7. Saisie quotidienne des données d’élevage**

L’éleveur doit pouvoir enregistrer quotidiennement les données relatives à chaque lot actif. Ces données comprennent la mortalité du jour, la consommation d’aliment, la consommation d’eau, le poids moyen, la production d’œufs et les observations éventuelles.

Cette saisie régulière permet de suivre l’évolution de l’élevage, d’identifier les problèmes de performance et de conserver un historique fiable des activités quotidiennes.

**8. Suivi sanitaire et vaccinations**

KIWO doit permettre la planification des vaccinations pour les lots de volailles. L’utilisateur peut renseigner le nom du vaccin, la voie d’administration, la dose prévue, la date planifiée et le lot concerné.

L’application doit également permettre de valider une vaccination réalisée en précisant la date réelle, la dose administrée et le nombre de sujets vaccinés. Cette fonctionnalité contribue à améliorer le contrôle sanitaire et à éviter les oublis de traitement.

**9. Historique et traçabilité des lots**

L’application doit conserver les événements importants liés à chaque lot. Ces événements peuvent concerner l’entrée du lot, les saisies quotidiennes, les vaccinations, les observations particulières et la clôture du lot.

Cette traçabilité permet à l’éleveur de consulter l’historique complet d’un lot et de disposer d’informations utiles pour l’analyse des performances ou la préparation de rapports.

**10. Tableau de bord et visualisation des indicateurs**

KIWO doit proposer un tableau de bord permettant de visualiser rapidement l’état général de l’élevage. Ce tableau de bord peut afficher le nombre de bâtiments, le nombre de lots, les types de volailles, les vaccinations à venir, les alertes et certains indicateurs de performance.

Grâce à cette vue synthétique, l’utilisateur peut prendre des décisions plus rapidement et identifier les éléments nécessitant une attention particulière.

**11. Gestion des appareils IoT et des lectures de capteurs**

L’application doit permettre d’ajouter et de gérer des appareils IoT associés à un bâtiment ou à un lot. Chaque appareil peut disposer d’un identifiant, d’un nom, d’un type, d’un statut et d’une date de dernière synchronisation.

KIWO doit également permettre la consultation des mesures envoyées par les capteurs, notamment la température, l’humidité, le CO2, la pression ou la luminosité lorsque ces données sont disponibles. Cette fonctionnalité renforce le contrôle de l’environnement d’élevage.

**12. Alertes et notifications**

L’application doit proposer un espace dédié aux alertes et notifications. Ces notifications peuvent concerner les rappels de vaccination, les événements importants ou les anomalies détectées dans le suivi de l’élevage.

Cette fonctionnalité permet d’informer l’utilisateur au bon moment et de réduire le risque d’oubli dans les tâches importantes.

**13. Thème et personnalisation de l’interface**

KIWO doit offrir une expérience visuelle confortable à travers la prise en charge du thème clair et du thème sombre. Le choix du thème doit être conservé afin que l’utilisateur retrouve ses préférences lors des prochaines utilisations.

Cette fonctionnalité améliore le confort d’utilisation et rend l’application plus agréable dans différents contextes d’éclairage.

### 1.4.3 Les besoins non fonctionnels

Les besoins non fonctionnels définissent les qualités que l’application doit respecter afin d’assurer une expérience fiable, sécurisée et durable.

**Ergonomie** : KIWO doit proposer une interface simple, claire et facile à utiliser. Les fonctionnalités doivent être organisées de manière logique afin que l’éleveur puisse accéder rapidement aux informations essentielles sans difficulté.

**Performance et réactivité** : l’application doit répondre rapidement aux actions de l’utilisateur. Les écrans de consultation, les formulaires et le tableau de bord doivent offrir une navigation fluide pour garantir une utilisation efficace au quotidien.

**Sécurité et confidentialité** : les données de l’élevage et les informations personnelles des utilisateurs doivent être protégées. L’accès aux données doit dépendre de l’authentification et du rôle de l’utilisateur. Les règles de sécurité Firestore doivent empêcher les accès non autorisés.

**Fiabilité des données** : les informations enregistrées doivent être cohérentes, correctement associées à l’utilisateur concerné et disponibles lors des consultations ultérieures. La fiabilité est essentielle pour garantir un suivi exact des lots, des bâtiments et des vaccinations.

**Compatibilité mobile** : KIWO doit fonctionner sur les principales plateformes mobiles prises en charge par Flutter. L’interface doit s’adapter aux différentes tailles d’écran afin d’assurer une expérience homogène.

**Maintenabilité** : le code de l’application doit être structuré par fonctionnalités et organisé en couches afin de faciliter les corrections, les évolutions et l’ajout de nouveaux modules.

**Évolutivité** : l’application doit pouvoir accueillir de nouvelles fonctionnalités dans le futur, comme des indicateurs avancés, des rapports détaillés, une meilleure automatisation IoT ou une analyse plus poussée des performances.

**Disponibilité et synchronisation** : grâce à Firebase et Cloud Firestore, les données doivent pouvoir être synchronisées efficacement afin que l’utilisateur dispose d’informations à jour. Cette synchronisation est particulièrement importante pour les données de suivi quotidien, les notifications et les mesures IoT.

## 1.5 Conclusion

Ce chapitre a présenté le contexte général du projet KIWO, l’étude des solutions existantes, leurs limites ainsi que les objectifs à atteindre. Il a également permis d’identifier les principaux acteurs de l’application et de définir les besoins fonctionnels et non fonctionnels nécessaires à la réalisation du système.

KIWO se positionne comme une solution mobile adaptée à la gestion d’un élevage avicole connecté. En centralisant les données de l’exploitation, en facilitant le suivi des lots et des bâtiments, en intégrant les vaccinations, les saisies quotidiennes et les données IoT, l’application vise à améliorer l’organisation, la traçabilité et la prise de décision de l’éleveur.

Le chapitre suivant sera consacré à l’analyse et à la conception de l’application. Il présentera la méthodologie adoptée, les diagrammes UML et l’architecture générale du système.

## Webographie indicative

- Farmbrite, plateforme de gestion agricole et de suivi du bétail : https://www.farmbrite.com/
- CoopSense, logiciel de gestion avicole : https://www.coopsense.com/
- PoultryCare, ERP de gestion avicole : https://www.poultry.care/
- Broilr, ERP et solution de gestion pour élevages de poulets de chair : https://broilr.app/
