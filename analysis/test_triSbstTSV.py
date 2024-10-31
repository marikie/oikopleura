import unittest
import triSbstTSV as script
import subprocess


class TestTriSbstTSV(unittest.TestCase):
    def test_main(self):
        print("test_main")

        # inputs
        self.in1_maf = open("./test/test_triSbstTSV.maf")
        self.outPath1 = "./test/result_triSbstTSV_out1.tsv"

        # expected outputs
        self.out1_tsv = "./test/test_triSbstTSV_out1.tsv"

        ### test1 ###
        print("test1")
        # Run the main function with test data
        script.main(self.in1_maf, self.outPath1)
        # Check if the contents of the two files (result and expected) are the same using diff
        result = subprocess.run(
            ["diff", self.outPath1, self.out1_tsv], capture_output=True
        )
        print("result.returncode: ", result.returncode)
        self.assertEqual(result.returncode, 0, "The files are different")


if __name__ == "__main__":
    unittest.main()
