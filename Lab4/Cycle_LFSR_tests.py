import unittest
import compile_helpers as chs;

def CYCLE_LFSR( state, tap):
    x = state & tap
    new_bit = chs.redXOR(x)
    nextState = state | new_bit
    nextState = nextState << 1
    return nextState

class MyTestCase(unittest.TestCase):


    def test_tap_60_seed_1_cyle_1(self):
         tap  = int('01100000', 2)
         init = int('00000001', 2)
         nextState = CYCLE_LFSR(init, tap)
         expected = int('00000010', 2)
         self.assertEqual("{:08b}".format(expected),"{:08b}".format(nextState))


    def test_tap_60_seed_1_cyle_2(self):
         tap  = int('01100000', 2)
         init = int('00000010', 2)
         nextState = CYCLE_LFSR(init, tap)
         expected = int('00000100', 2)
         self.assertEqual("{:08b}".format(expected), "{:08b}".format(nextState))


if __name__ == '__main__':
    unittest.main()
