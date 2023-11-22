- oik_lanc_intersect_oik_anno_20231106.out
  - $1: chromosome name of oik (aligned part)
    $2: start coord (inbetween)
    $3: end coord (inbetween)
    $4: strand
    $5: chromosome name of lancelet (aligned part)
    $6: start coord (inbetween)
    $7: end coord (inbetween)
    $8: chromosome name of oik (annotation)
    $9: start coord (inbetween)
    $10: end coord (inbetween)
    $11: geneID
    $12: .
    $13: strand

- /oik_lanc_intersect_oik_anno
  - /multiAlnSegOnTheSameQryGene
    each .out 
      - $1: oik chromosome (aligned part)
        $2: start
        $3: end
        $4: strand
        $5: lancelet chromosome (aligned part)
        $6: start
        $7: end
        $8: oik chromosome (overlapping annotation)
        $9: start
        $10: end
        $11: geneID
        $12: .
        $13: strand
    each ref.*.out
      - $1: lancelet chromosome (aligned part)
        $2: start
        $3: end
        $4: oik chromosome (aligned part)
        $5: start
        $6: end
        $7: strand
        $8: oik chromosome (overlapping annotation) 
        $9: start
        $10: end
        $11: geneID
        $12: strand
