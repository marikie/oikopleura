/*
* pipeline input parameters
*/
params.refg = file('/big/mrk/oikopleura/last/OKI2018_I69_1.0.fa')
params.dbName = toString("${params.refg.getBaseName()}")
params.read1 = "/big/mrk/oikopleura/rna-seq-data/embryos/ERR4570985_1_filtered_trimmed_sorted.fastq"
params.read2 = "/big/mrk/oikopleura/rna-seq-data/embryos/ERR4570985_2_filtered_trimmed_sorted.fastq"
//params.
params.outdir = "/big/mrk/oikopleura/olg_finder_embryos"
log.info """\
    O L G _ F I N D E R  P I P E L I N E
    reference genome: ${params.refg}
    dbName          : ${params.dbName}
    read1           : ${params.read1}
    read2           : ${params.read2}
    outdir          : ${params.outdir}
    """
    .stripIndent()

/*
* LAST alignment
*/
// --- lastdb ---
process LASTDB_LASTTRAIN {
    input:
    path refgFilePath
    path dbName
    path read1

    output:
    path 'last-train_out'    

 
    script:
    """
    lastdb -P8 -uNEAR $dbName $refgFilePath
    last-train -P8 -Q0 $dbName $read1 > last-train_out
    """
    // Q0: fasta or fastq
}

workflow {
    lastdb_lasttrain_ch = LASTDB_LASTTRAIN(params.refg, params.dbName, params.read1) 
    lastdb_lasttrain_ch.view()
}
