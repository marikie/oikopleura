import unittest
import split2twoFiles as script
import subprocess


class TestSplit2TwoFiles(unittest.TestCase):
    def test_main(self):
        print("test_main")

        # inputs
        self.in1_tsv = "./test/test_split2twoFiles_in1.tsv"
        self.outPath1_B = "./test/result_split2twoFiles_out1_B.tsv"
        self.outPath1_C = "./test/result_split2twoFiles_out1_C.tsv"

        # expected outputs
        self.out1_B_tsv = "./test/test_split2twoFiles_out1_B.tsv"
        self.out1_C_tsv = "./test/test_split2twoFiles_out1_C.tsv"

        ### test1 ###
        print("test1")
        # Run the main function with test data
        script.main(self.in1_tsv, self.outPath1_B, self.outPath1_C)
        # Check speciesB: if the contents of the result are the same with the expected files
        result = subprocess.run(
            ["diff", "-b", self.outPath1_B, self.out1_B_tsv], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different: B")
        # Check speciesC: if the contents of the result are the same with the expected files
        result = subprocess.run(
            ["diff", "-b", self.outPath1_C, self.out1_C_tsv], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different: C")


if __name__ == "__main__":
    unittest.main()
