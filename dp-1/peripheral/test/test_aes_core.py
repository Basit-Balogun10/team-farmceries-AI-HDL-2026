"""
AES Core Full Encryption Tests  
Tests complete 10-round AES-128 encryption with NIST test vectors
"""

import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

# NIST FIPS-197 Appendix C Test Vectors
# Test Vector 1
PLAINTEXT_1  = 0x00112233445566778899aabbccddeeff
KEY_1        = 0x000102030405060708090a0b0c0d0e0f
CIPHERTEXT_1 = 0x69c4e0d86a7b0430d8cdb78070b4c55a

# Test Vector 2 (all zeros)
PLAINTEXT_2  = 0x00000000000000000000000000000000
KEY_2        = 0x00000000000000000000000000000000
CIPHERTEXT_2 = 0x66e94bd4ef8a2c3b884cfa59ca342b2e

@cocotb.test()
async def test_aes_encryption_nist_vector_1(dut):
    """Test AES encryption with NIST test vector 1"""
    
    # Create clock
    clock = Clock(dut.clk, 10, units="ns")  # 100MHz clock
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.start.value = 0
    dut.mode.value = 0  # Encrypt mode
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Load inputs
    dut.plaintext.value = PLAINTEXT_1
    dut.key.value = KEY_1
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0
    
    # Wait for encryption to complete
    while dut.done.value == 0:
        await RisingEdge(dut.clk)
    
    # Check output
    actual_ciphertext = dut.ciphertext.value.integer
    assert actual_ciphertext == CIPHERTEXT_1, \
        f"Encryption failed: got 0x{actual_ciphertext:032x}, expected 0x{CIPHERTEXT_1:032x}"
    
    dut._log.info(f"✓ NIST test vector 1 passed")
    dut._log.info(f"  Plaintext:  0x{PLAINTEXT_1:032x}")
    dut._log.info(f"  Key:        0x{KEY_1:032x}")
    dut._log.info(f"  Ciphertext: 0x{actual_ciphertext:032x}")

@cocotb.test()
async def test_aes_encryption_nist_vector_2(dut):
    """Test AES encryption with NIST test vector 2 (all zeros)"""
    
    # Create clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    dut.start.value = 0
    dut.mode.value = 0  # Encrypt mode
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Load inputs
    dut.plaintext.value = PLAINTEXT_2
    dut.key.value = KEY_2
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0
    
    # Wait for encryption to complete
    while dut.done.value == 0:
        await RisingEdge(dut.clk)
    
    # Check output
    actual_ciphertext = dut.ciphertext.value.integer
    assert actual_ciphertext == CIPHERTEXT_2, \
        f"Encryption failed: got 0x{actual_ciphertext:032x}, expected 0x{CIPHERTEXT_2:032x}"
    
    dut._log.info(f"✓ NIST test vector 2 (all zeros) passed")

@cocotb.test()
async def test_aes_timing(dut):
    """Verify AES encryption timing (~24 cycles)"""
    
    # Create clock  
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset
    dut.rst_n.value = 0
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)
    
    # Start encryption
    dut.plaintext.value = PLAINTEXT_1
    dut.key.value = KEY_1
    dut.mode.value = 0
    dut.start.value = 1
    
    start_time = cocotb.utils.get_sim_time(units='ns')
    await RisingEdge(dut.clk)
    dut.start.value = 0
    
    # Wait for done
    while dut.done.value == 0:
        await RisingEdge(dut.clk)
    
    end_time = cocotb.utils.get_sim_time(units='ns')
    elapsed_cycles = (end_time - start_time) / 10  # 10ns clock period
    
    dut._log.info(f"✓ Encryption completed in {elapsed_cycles:.0f} clock cycles")
    
    # Should be approximately 24 cycles (may vary slightly based on implementation)
    assert 15 <= elapsed_cycles <= 35, \
        f"Timing unexpected: {elapsed_cycles:.0f} cycles (expected ~24)"
