---
name: team-sync
description: >
  Coordination d'équipe pour projets multi-dev avec PAUL. Affiche l'état
  de chaque dev, détecte les conflits de phase, facilite les handoffs.
  Se déclenche quand l'utilisateur mentionne "sync", "team sync",
  "coordination", "qui travaille sur quoi", "handoff", "conflit",
  ou "ownership".
---

# Team Sync — Coordination Multi-Dev

Skill de coordination pour équipes travaillant avec PAUL + Compound.
Fournit une vue d'ensemble de l'état de l'équipe et détecte les conflits.

---

## When to trigger

- Début de session (après lecture des MEMORY files)
- Avant de commencer une nouvelle phase
- Quand un dev veut savoir ce que fait l'autre
- Avant un handoff
- Quand on soupçonne un conflit (2 devs sur la même phase)

---

## Exécution

### Étape 1 — Collecter l'état de chaque dev

Lire tous les fichiers `memory/MEMORY-*.md` (sauf MEMORY-shared.md).
Pour chaque dev, extraire :
- Dernière session (date)
- Phase/task courante
- Prochaine étape
- Blocages

### Étape 2 — Lire l'ownership

Lire `memory/MEMORY-shared.md` → section "Ownership phases".
Lire `.paul/ROADMAP.md` pour la progression globale.

### Étape 3 — Détecter les conflits

Conflits à signaler :
- Deux devs sur la même phase sans coordination explicite (mode 2 non déclaré)
- Un dev travaille sur une phase marquée comme complétée
- Un handoff en attente non lu (fichier dans handoffs/ plus récent que la dernière session du dev)
- MEMORY-shared.md modifié depuis la dernière session du dev courant

### Étape 4 — Rapport

```markdown
## Team Sync — {date}

### État des devs

| Dev | Phase | Task | Dernière session | Prochaine étape | Blocages |
|-----|-------|------|-----------------|-----------------|----------|
| {dev1} | {N} | {task} | {date} | {next} | {blocages ou "Aucun"} |
| {dev2} | {N} | {task} | {date} | {next} | {blocages ou "Aucun"} |

### Progression globale
Phase {N}/{total} — {pourcentage}% du roadmap

### Alertes
- {alerte si conflit détecté, sinon "Aucune alerte"}

### Action recommandée pour {dev courant}
{Une seule action, claire et actionnable}
```

---

## Faciliter un handoff

Quand le dev courant veut faire un handoff :

1. Vérifier que `/paul:unify` a été exécuté (pas de travail orphelin)
2. Vérifier que MEMORY-{moi}.md est à jour
3. Vérifier que le code est commité et pushé
4. Suggérer `/paul:handoff` pour générer le fichier
5. Confirmer que le fichier handoff est dans `handoffs/` et commité

Quand le dev courant reçoit un handoff :

1. Lister les fichiers dans `handoffs/` triés par date
2. Présenter le résumé du handoff le plus récent
3. Vérifier la cohérence avec MEMORY-shared.md
4. Proposer la prochaine action

---

## Ce que ce skill ne fait PAS

- Modifier des fichiers (read-only, sauf rapport si demandé)
- Résoudre les merge conflicts git (c'est du git standard)
- Forcer un dev à changer de phase (suggestion seulement)
- Remplacer la communication directe entre devs
