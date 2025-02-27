import unittest
import triUvMuts_2TSVs_errprb as script
import subprocess


class TestTriUvMuts2TSVs(unittest.TestCase):
    def test_main(self):
        print("test_main")

        # inputs
        self.in1_maf = open("./test/test_triUvMuts2TSVs_errprb_in1.maf")
        self.org2outPath1 = "./test/result_triUvMuts2TSVs_errprb_out1_2.tsv"
        self.org3outPath1 = "./test/result_triUvMuts2TSVs_errprb_out1_3.tsv"

        # expected outputs
        self.out1_2 = "./test/test_triUvMuts2TSVs_errprb_out1_2.tsv"
        self.out1_3 = "./test/test_triUvMuts2TSVs_errprb_out1_3.tsv"

        ### test1 ###
        print("test1")
        # Run the main function with test data
        script.main(self.in1_maf, self.org2outPath1, self.org3outPath1)
        # Check if the contents of the two files (result and expected) are the same using diff
        result = subprocess.run(
            ["diff", "-b", self.org2outPath1, self.out1_2], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")
        result = subprocess.run(
            ["diff", "-b", self.org3outPath1, self.out1_3], capture_output=True
        )
        self.assertEqual(result.returncode, 0, "The files are different")

    def test_bothEdgeBasesSame(self):
        print("test_bothEdgeBasesSame")
        self.assertTrue(script.bothEdgeBasesSame("AAA", "ATA", "ACA"))
        self.assertTrue(script.bothEdgeBasesSame("AAA", "AAA", "AAA"))
        self.assertFalse(script.bothEdgeBasesSame("TAA", "ATA", "AGA"))
        self.assertFalse(script.bothEdgeBasesSame("AAA", "AAA", "AAC"))

    def test_rev(self):
        print("test_rev")
        self.assertEqual(script.rev("AAA"), "TTT")
        self.assertEqual(script.rev("ATA"), "TAT")
        self.assertEqual(script.rev("ACA"), "TGT")
        self.assertEqual(script.rev("ACC"), "GGT")

    def test_mutType(self):
        print("test_mutType")
        self.assertEqual(script.mutType("AAA", "A", "G"), "TTTC")
        self.assertEqual(script.mutType("ACG", "C", "T"), "ACGT")

    def test_add2totalNum(self):
        print("test_add2totalNum")
        mutDict = script.initialize_mut_dict()
        exp_mutDict = script.initialize_mut_dict()
        exp_mutDict["CTGA"] = {"mutNum": 0, "totalRootNum": 1}
        exp_mutDict["CTGC"] = {"mutNum": 0, "totalRootNum": 1}
        exp_mutDict["CTGG"] = {"mutNum": 0, "totalRootNum": 1}
        script.add2totalNum(mutDict, "CTG")
        self.assertEqual(mutDict, exp_mutDict)

        mutDict = script.initialize_mut_dict()
        exp_mutDict = script.initialize_mut_dict()
        exp_mutDict["CTGA"] = {"mutNum": 0, "totalRootNum": 1}
        exp_mutDict["CTGC"] = {"mutNum": 0, "totalRootNum": 1}
        exp_mutDict["CTGG"] = {"mutNum": 0, "totalRootNum": 1}
        script.add2totalNum(mutDict, "CAG")
        self.assertEqual(mutDict, exp_mutDict)

    def test_add2MutDict(self):
        print("test_add2MutDict")
        mutDict2 = script.initialize_mut_dict()
        mutDict3 = script.initialize_mut_dict()
        script.add2MutDict("CAG", "CGG", "CAG", mutDict2, mutDict3)
        exp_mutDict2 = script.initialize_mut_dict()
        exp_mutDict2["CTGA"] = {"mutNum": 0, "totalRootNum": 1}
        exp_mutDict2["CTGC"] = {"mutNum": 1, "totalRootNum": 1}
        exp_mutDict2["CTGG"] = {"mutNum": 0, "totalRootNum": 1}
        exp_mutDict3 = script.initialize_mut_dict()
        exp_mutDict3["CTGA"] = {"mutNum": 0, "totalRootNum": 1}
        exp_mutDict3["CTGC"] = {"mutNum": 0, "totalRootNum": 1}
        exp_mutDict3["CTGG"] = {"mutNum": 0, "totalRootNum": 1}

        # Set maxDiff to None to see the full diff
        self.maxDiff = None

        # # Print the dictionaries for debugging
        # print("mutDict2:", mutDict2)
        # print("exp_mutDict2:", exp_mutDict2)
        # print("mutDict3:", mutDict3)
        # print("exp_mutDict3:", exp_mutDict3)

        self.assertEqual(mutDict2, exp_mutDict2)
        self.assertEqual(mutDict3, exp_mutDict3)


if __name__ == "__main__":
    unittest.main()
