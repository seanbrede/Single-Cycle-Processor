import unittest
import Lab4.compile_helpers as chs;

def clear_parity( bitString ):
    parity = bitString & 128
    clearedParityBitString = bitString ^ parity
    return clearedParityBitString


class MyTestCase(unittest.TestCase):

    def test_getting_parity_1(self):
        testVal = int('10000001', 2)
        actual   = testVal & 128
        expected = int('10000000', 2)
        self.assertEqual("{:08b}".format(expected), "{:08b}".format(actual))

    def test_getting_parity_0(self):
        testVal = int('00000001', 2)
        actual   = testVal & 128
        expected = int('00000000', 2)
        self.assertEqual("{:08b}".format(expected), "{:08b}".format(actual))

    def test_remove_parity(self):
        testVal = int('10101001', 2)
        actual  = clear_parity(testVal)
        expected = int('00101001', 2)
        self.assertEqual("{:08b}".format(expected), "{:08b}".format(actual))

if __name__ == '__main__':
    unittest.main()
