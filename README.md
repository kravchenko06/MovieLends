# **ETL proces datasetu MovieLens**

Tento repozitár obsahuje implementáciu ETL procesu v Snowflake pre analýzu dát z datasetu MovieLens. Projekt sa zameriava na preskúmanie informácií o filmoch, ich hodnoteniach a demografických údajoch používateľov. Výsledný dátový model umožňuje multidimenzionálnu analýzu a vizualizáciu kľúčových metrik.

---
## **1. Úvod a popis zdrojových dát**
Cieľom projektu je analyzovať dáta týkajúce sa filmov, ich žánrov, hodnotení a správania používateľov. Táto analýza umožňuje identifikovať trendy vo filmových preferenciách, najpopulárnejšie filmy a správanie divákov.

Zdrojové dáta sú štruktúrované v relačnej databáze a obsahujú nasledujúce hlavné tabuľky:

- `movies`
- `genres`
- `genres_movies`
- `ratings`
- `names`
- `ratings`
- `tags`
- `users`
- `occupations`
- `age_group`

Účelom ETL procesu bolo tieto dáta pripraviť, transformovať a sprístupniť pre viacdimenzionálnu analýzu.

---
### **1.1 Dátová architektúra**

### **ERD diagram**
Surové dáta sú usporiadané v relačnom modeli, ktorý je znázornený na **entitno-relačnom diagrame (ERD)**:

<p align="center">
  <img src="https://github.com/kravchenko06/MovieLends/blob/main/erd_schema.png">
  <br>
  <em>Obrázok 1 Entitno-relačná schéma IMDb</em>
</p>

---
