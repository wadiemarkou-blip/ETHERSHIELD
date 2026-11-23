# Rapport d'audit pédagogique — EtherShield

## Périmètre
Revue pédagogique de Vault, AccessControl, AdminPanel, TxOriginWallet, SigVault, Auction et RefundDoS. Ce document ne constitue pas un audit indépendant certifié.

| ID | Finding | Sévérité pédagogique | Cause racine | Remédiation |
|---|---|---|---|---|
| ES-01 | Reentrancy | Critique | Appel externe avant mise à jour de l'état | Checks-Effects-Interactions + ReentrancyGuard |
| ES-02 | Contrôle d'accès absent | Haute | Fonctions administratives publiques | onlyOwner, validation des paramètres |
| ES-03 | Authentification tx.origin | Haute | Origine de transaction confondue avec appelant | msg.sender |
| ES-04 | Signature replay | Haute | Pas de nonce/expiration/domaine | EIP-712, nonce, deadline |
| ES-05 | Front-running / MEV | Moyenne/Haute | Offres publiques en clair | Commit-reveal lié au bidder et au contrat |
| ES-06 | Refund DoS | Haute | Push refund qui revert bloque la mise | Pull payments |

## Procédure de validation
Pour chaque finding : lancer le test `test_Exploit_*`, relever l'état et l'impact, lancer le test `test_Fixed_*`, vérifier le blocage de l'attaque et le fonctionnement légitime.

## Slither
Exécuter `slither . --config-file slither.config.json`, joindre la sortie réelle, classifier sévérité/confiance, confirmer ou écarter les faux positifs. Aucune sortie Slither n'est inventée dans ce rapport.

## Limites résiduelles
Commit-reveal n'élimine pas tous les risques MEV (censure, non-révélation, griefing, timing). Les tests ne garantissent pas l'absence totale de vulnérabilités. Toute utilisation réelle exige dépendances officielles, revue indépendante et tests supplémentaires.
