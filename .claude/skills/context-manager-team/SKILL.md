---
name: context-manager-team
description: >
  Gestion du contexte et de la mémoire pour équipes multi-dev avec PAUL.
  Charger automatiquement sur tout projet qui utilise MEMORY-shared.md,
  MEMORY-{dev}.md, ou PAUL. Se déclenche quand l'utilisateur mentionne
  "contexte", "mémoire", "reprendre", "session", "MEMORY", ou "checkpoint".
---

# Context Manager — Team Edition

Règles pour maintenir la qualité sur des sessions longues en environnement
multi-dev, gérer la mémoire partagée et personnelle, et structurer les
handoffs entre développeurs.

---

## Règles critiques — s'appliquent toujours

### Démarrage de session

TOUJOURS lire dans cet ordre avant de coder ou planifier :

1. memory/MEMORY-shared.md       → décisions d'équipe, architecture, conventions
2. memory/MEMORY-{moi}.md        → mon état perso, position, blocages
3. docs/solutions/{domaine}/     → patterns connus sur le domaine du jour
4. Supermemory query             → leçons cross-projet si domaine connu
5. handoffs/ (le plus récent)    → si quelqu'un a fait un handoff récemment

Si MEMORY-shared.md n'existe pas → le créer depuis le template.
Si MEMORY-{moi}.md n'existe pas → le créer depuis le template.
Ne jamais supposer le contexte. Toujours le lire.

### Fin de session

1. Mettre à jour MEMORY-{moi}.md :
   - Ce qui a été fait (3-5 lignes max)
   - Décisions prises + raison courte
   - Une seule prochaine étape, claire et actionnable
   - Blocages ou questions ouvertes

2. Si décision impacte l'équipe → proposer mise à jour MEMORY-shared.md :
   - Présenter la décision clairement
   - Demander validation avant d'écrire
   - Ajouter dans le tableau "Architecture retenue" avec date et auteur

3. Commiter les MEMORY files dans le même commit que le code produit.

---

## Gestion des sessions longues

### Détecter la dégradation du contexte

Signaux d'alerte :

- Claude répète des questions déjà répondues
- Réponses moins précises ou qui ignorent des contraintes établies
- Contexte à ~60-70% de capacité utilisée
- Incohérences avec des décisions prises en début de session

Action : "Contexte à [X]% — checkpoint recommandé avant de continuer."

### Protocole checkpoint

1. Résumer l'état en moins de 200 mots dans MEMORY-{moi}.md
2. Lister les décisions prises depuis le début de session
3. Identifier la prochaine tâche (une seule, actionnable)
4. Proposer d'ouvrir une nouvelle session

Règle absolue : ne jamais continuer une session dégradée.

---

## Protocole de handoff

### Avant un handoff

1. `/paul:unify` OBLIGATOIRE — pas de travail orphelin
2. Mettre à jour MEMORY-{moi}.md complètement
3. `/paul:handoff` → génère fichier dans handoffs/
4. Git commit + push

### Après réception d'un handoff

1. Lire MEMORY-shared.md (contexte équipe)
2. Lire le fichier handoff le plus récent dans handoffs/
3. Lire MEMORY-{moi}.md (mon propre état)
4. Consulter docs/solutions/ pour patterns pertinents
5. Résumer à voix haute ce qu'on comprend avant de commencer

---

## Promotion de décisions

Quand une décision locale doit devenir une décision d'équipe :

1. Vérifier que la décision est stable (testée, pas en cours de changement)
2. Formuler clairement : quoi, pourquoi, alternatives rejetées
3. Ajouter dans MEMORY-shared.md → tableau "Architecture retenue"
4. Commiter MEMORY-shared.md séparément ou avec le code concerné

---

## Chain of thought — externaliser avant d'exécuter

Obligatoire pour : architecture, logique métier complexe, debug difficile, choix techniques.

```
Problème : [ce qu'on résout exactement]
Contraintes : [limites connues]
Options :
  A) [option] → avantage / inconvénient
  B) [option] → avantage / inconvénient
Choix : [option] parce que [raison courte]
Risques : [ce qui pourrait mal tourner]
```

---

## Hiérarchie des couches mémoire

| Information | Où la mettre |
|-------------|-------------|
| Décisions d'équipe, architecture | memory/MEMORY-shared.md |
| État perso, position, blocages | memory/MEMORY-{moi}.md |
| Pattern résolu sur CE projet | docs/solutions/{domaine}/ |
| Pattern réutilisable cross-projets | docs/solutions/ + CARL |
| Leçon cross-projet | Supermemory |
| Code et implémentation | Git |
| Credentials et secrets | .env (jamais dans mémoire) |
| Contexte de handoff | handoffs/ |

---

## Anti-patterns

- Commencer sans lire MEMORY-shared + MEMORY-{moi}
- Modifier MEMORY-shared sans validation d'équipe
- Faire un handoff sans /paul:unify
- Continuer une session dégradée
- Sauvegarder dans Supermemory sans tag structuré
- Dupliquer un pattern au lieu de mettre à jour
- Stocker des données sensibles dans les MEMORY files
