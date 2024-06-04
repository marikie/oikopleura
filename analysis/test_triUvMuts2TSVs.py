import unittest
import triUvMuts_2TSVs as script
import subprocess


class TestTriUvMuts2TSVs(unittest.TestCase):
    def setUp(self):
        print("setUp")
        # inputs
        self.in1_maf = open("./test/test_triUvMuts2TSVs_in1.maf")
        self.org2outPath1 = "./test/result_out1_2.tsv"
        self.org3outPath1 = "./test/result_out1_3.tsv"
        self.in2_maf = open("./test/test_triUvMuts2TSVs_in2.maf")
        self.org2outPath2 = "./test/result_out2_2.tsv"
        self.org3outPath2 = "./test/result_out2_3.tsv"
        self.in3_maf = open("./test/test_triUvMuts2TSVs_in3.maf")
        self.org2outPath3 = "./test/result_out3_2.tsv"
        self.org3outPath3 = "./test/result_out3_3.tsv"
        self.in4_maf = open("./test/test_triUvMuts2TSVs_in4.maf")
        self.org2outPath4 = "./test/result_out4_2.tsv"
        self.org3outPath4 = "./test/result_out4_3.tsv"
        self.in5_maf = open("./test/test_triUvMuts2TSVs_in5.maf")
        self.org2outPath5 = "./test/result_out5_2.tsv"
        self.org3outPath5 = "./test/result_out5_3.tsv"
        self.in6_maf = open("./test/test_triUvMuts2TSVs_in6.maf")
        self.org2outPath6 = "./test/result_out6_2.tsv"
        self.org3outPath6 = "./test/result_out6_3.tsv"

        # expected outputs
        self.out_all0 = "./test/test_triUvMuts2TSVs_out_all0.tsv"
        self.out3_2 = "./test/test_triUvMuts2TSVs_out3_2.tsv"
        self.out3_3 = "./test/test_triUvMuts2TSVs_out3_3.tsv"
        self.out4_2 = "./test/test_triUvMuts2TSVs_out4_2.tsv"
        self.out4_3 = "./test/test_triUvMuts2TSVs_out4_3.tsv"
        self.out6_2 = "./test/test_triUvMuts2TSVs_out6_2.tsv"
        self.out6_3 = "./test/test_triUvMuts2TSVs_out6_3.tsv"

    def test_main(self):
        print("test_main")

        ### test1 ###
        ### not a signature ###
        print("test1")
        # Run the main function with test data
        script.main(self.in1_maf, self.org2outPath1, self.org3outPath1)
        # Check if the contents of the two files (result and expected) are the same using diff
        result = subprocess.run(
            ["diff", self.org2outPath1, self.out_all0], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")
        result = subprocess.run(
            ["diff", self.org3outPath1, self.out_all0], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")

        ### test2 ###
        ### signature but mutation is on the org1, which is ambiguous, so no mutation count ###
        print("test2")
        script.main(self.in2_maf, self.org2outPath2, self.org3outPath2)
        result = subprocess.run(
            ["diff", self.org2outPath2, self.out_all0], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")
        result = subprocess.run(
            ["diff", self.org3outPath2, self.out_all0], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")

        ### test3 ###
        ### signature and mutation is on the org2 ###
        print("test3")
        script.main(self.in3_maf, self.org2outPath3, self.org3outPath3)
        result = subprocess.run(
            ["diff", self.org2outPath3, self.out3_2], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")
        result = subprocess.run(
            ["diff", self.org3outPath3, self.out3_3], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")

        ### test4 ###
        ### signature and mutation is on the org3 ###
        print("test4")
        script.main(self.in4_maf, self.org2outPath4, self.org3outPath4)
        result = subprocess.run(
            ["diff", self.org2outPath4, self.out4_2], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")
        result = subprocess.run(
            ["diff", self.org3outPath4, self.out4_3], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")

        ### test5 ###
        ### not a signature because there is a deletion ###
        print("test5")
        script.main(self.in5_maf, self.org2outPath5, self.org3outPath5)
        result = subprocess.run(
            ["diff", self.org2outPath5, self.out_all0], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")
        result = subprocess.run(
            ["diff", self.org3outPath5, self.out_all0], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")

        ### test6 ###
        ### multiple trinucs from a real data  ###
        print("test6")
        script.main(self.in6_maf, self.org2outPath6, self.org3outPath6)
        result = subprocess.run(
            ["diff", self.org2outPath6, self.out_all0], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")
        result = subprocess.run(
            ["diff", self.org3outPath6, self.out_all0], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")


if __name__ == "__main__":
    unittest.main()
