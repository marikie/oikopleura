import unittest
import subRatio as script


class TestSubRatio(unittest.TestCase):
    def test_count(self):
        print("test_count")
        # input
        self.in1 = "./test/test_subRatio_in1.maf"
        result = script.count(self.in1)
        self.assertEqual(result, (5, 11, 4, 12))


if __name__ == "__main__":
    unittest.main()
