# Démonstration finale (10–15 minutes)
1. Démarrer `anvil`, puis exécuter `forge build` et `forge test -vvv`.
2. Reentrancy : montrer le retrait vulnérable, expliquer l'appel externe avant mise à jour, puis la protection.
3. Access Control : montrer la modification non autorisée puis le revert avec onlyOwner.
4. tx.origin : présenter le contrat piège et le blocage par msg.sender.
5. Signature Replay : présenter la réutilisation d'une signature puis nonce, deadline et domaine EIP-712.
6. Front-running : expliquer la visibilité des offres publiques puis comparer commit-reveal.
7. Refund DoS : montrer le push refund qui bloque puis le retrait pull indépendant.
8. Présenter la sortie réelle Slither, findings confirmés, faux positifs et limites.
Pour chaque faille : cause racine, impact, preuve reproductible, correctif et résultat de validation.
