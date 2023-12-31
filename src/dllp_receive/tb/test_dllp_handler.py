import itertools
import logging
import os
import random
import subprocess
import sys

import cocotb_test.simulator
import pytest
import zlib, binascii, struct
from crc import Calculator, Configuration,Crc32

import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotbext.axi import AxiStreamFrame, AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor
from cocotbext.pcie.core import RootComplex, MemoryEndpoint, Device, Switch
from cocotbext.pcie.core.caps import MsiCapability
from cocotbext.pcie.core.utils import PcieId
from cocotbext.pcie.core.tlp import Tlp, TlpType
from cocotbext.pcie.core.dllp import Dllp, DllpType,FcScale


class TB:
    def __init__(self, dut):
        self.dut = dut

        ports = 2
 
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 2, units="ns").start())

        self.source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "s_axis"), dut.clk, dut.rst)
        #self.sink = [AxiStreamSink(AxiStreamBus.from_prefix(dut, f"m{k:02d}_axis"), dut.clk, dut.rst) for k in range(ports)]
        #self.sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis"), dut.clk, dut.rst)
        #self.sinkdllp = AxiStreamSink(AxiStreamBus.from_prefix(dut, "m_axis_dllp"), dut.clk, dut.rst)
        #self.monitor = AxiStreamMonitor(AxiStreamBus.from_prefix(dut, "axis"), dut.clk, dut.rst)

    def set_idle_generator(self, generator=None):
        if generator:
            self.source.set_pause_generator(generator())

    def set_backpressure_generator(self, generator=None):
        if generator:
            self.sink.set_pause_generator(generator())

    async def reset(self):
        self.dut.rst.setimmediatevalue(0)
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.rst.value = 0
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)

def cycle_pause():
    return itertools.cycle([1, 1, 1, 0])

def crc16(data, crc=0xFFFF, poly=0xD008):
    for d in data:
        crc = crc ^ d
        for bit in range(0, 8):
            if crc & 1:
                crc = (crc >> 1) ^ poly
            else:
                crc = crc >> 1
    return crc ^ 0xffff

# def crc32(data, crc=0xFFFFFFFF, poly=0x04C11DB7):
#     for d in data:
#         crc = crc ^ d
#         for bit in range(0, 8):
#             if crc & 1:
#                 crc = (crc >> 1) ^ poly
#             else:
#                 crc = crc >> 1
#     return crc
def crc(crcIn, data):
    class bitwrapper:
        def __init__(self, x):
            self.x = x
        def __getitem__(self, i):
            return (self.x >> i) & 1
        def __setitem__(self, i, x):
            self.x = (self.x | (1 << i)) if x else (self.x & ~(1 << i))
    crcIn = bitwrapper(crcIn)
    data = bitwrapper(data)
    ret = bitwrapper(0)
    ret[0] = crcIn[2] ^ crcIn[4] ^ crcIn[7] ^ crcIn[11] ^ crcIn[12] ^ crcIn[13] ^ crcIn[15] ^ data[0] ^ data[4] ^ data[5] ^ data[6] ^ data[9] ^ data[10] ^ data[11] ^ data[12] ^ data[13] ^ data[14] ^ data[18] ^ data[20] ^ data[23] ^ data[27] ^ data[28] ^ data[29] ^ data[31]
    ret[1] = crcIn[2] ^ crcIn[3] ^ crcIn[4] ^ crcIn[5] ^ crcIn[7] ^ crcIn[8] ^ crcIn[11] ^ crcIn[14] ^ crcIn[15] ^ data[0] ^ data[1] ^ data[4] ^ data[7] ^ data[9] ^ data[15] ^ data[18] ^ data[19] ^ data[20] ^ data[21] ^ data[23] ^ data[24] ^ data[27] ^ data[30] ^ data[31]
    ret[2] = crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[11] ^ crcIn[13] ^ data[0] ^ data[1] ^ data[2] ^ data[4] ^ data[6] ^ data[8] ^ data[9] ^ data[11] ^ data[12] ^ data[13] ^ data[14] ^ data[16] ^ data[18] ^ data[19] ^ data[21] ^ data[22] ^ data[23] ^ data[24] ^ data[25] ^ data[27] ^ data[29]
    ret[3] = crcIn[1] ^ crcIn[3] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ crcIn[14] ^ data[1] ^ data[2] ^ data[3] ^ data[5] ^ data[7] ^ data[9] ^ data[10] ^ data[12] ^ data[13] ^ data[14] ^ data[15] ^ data[17] ^ data[19] ^ data[20] ^ data[22] ^ data[23] ^ data[24] ^ data[25] ^ data[26] ^ data[28] ^ data[30]
    ret[4] = crcIn[0] ^ crcIn[5] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[8] ^ data[9] ^ data[12] ^ data[15] ^ data[16] ^ data[21] ^ data[24] ^ data[25] ^ data[26] ^ data[28]
    ret[5] = crcIn[0] ^ crcIn[1] ^ crcIn[2] ^ crcIn[4] ^ crcIn[6] ^ crcIn[7] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ crcIn[15] ^ data[0] ^ data[1] ^ data[3] ^ data[5] ^ data[11] ^ data[12] ^ data[14] ^ data[16] ^ data[17] ^ data[18] ^ data[20] ^ data[22] ^ data[23] ^ data[25] ^ data[26] ^ data[28] ^ data[31]
    ret[6] = crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[5] ^ crcIn[7] ^ crcIn[8] ^ crcIn[10] ^ crcIn[11] ^ crcIn[13] ^ data[1] ^ data[2] ^ data[4] ^ data[6] ^ data[12] ^ data[13] ^ data[15] ^ data[17] ^ data[18] ^ data[19] ^ data[21] ^ data[23] ^ data[24] ^ data[26] ^ data[27] ^ data[29]
    ret[7] = crcIn[0] ^ crcIn[3] ^ crcIn[6] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[13] ^ crcIn[14] ^ crcIn[15] ^ data[0] ^ data[2] ^ data[3] ^ data[4] ^ data[6] ^ data[7] ^ data[9] ^ data[10] ^ data[11] ^ data[12] ^ data[16] ^ data[19] ^ data[22] ^ data[23] ^ data[24] ^ data[25] ^ data[29] ^ data[30] ^ data[31]
    ret[8] = crcIn[1] ^ crcIn[2] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[11] ^ crcIn[12] ^ crcIn[13] ^ crcIn[14] ^ data[0] ^ data[1] ^ data[3] ^ data[6] ^ data[7] ^ data[8] ^ data[9] ^ data[14] ^ data[17] ^ data[18] ^ data[24] ^ data[25] ^ data[26] ^ data[27] ^ data[28] ^ data[29] ^ data[30]
    ret[9] = crcIn[2] ^ crcIn[3] ^ crcIn[9] ^ crcIn[10] ^ crcIn[11] ^ crcIn[12] ^ crcIn[13] ^ crcIn[14] ^ crcIn[15] ^ data[1] ^ data[2] ^ data[4] ^ data[7] ^ data[8] ^ data[9] ^ data[10] ^ data[15] ^ data[18] ^ data[19] ^ data[25] ^ data[26] ^ data[27] ^ data[28] ^ data[29] ^ data[30] ^ data[31]
    ret[10] = crcIn[0] ^ crcIn[2] ^ crcIn[3] ^ crcIn[7] ^ crcIn[10] ^ crcIn[14] ^ data[0] ^ data[2] ^ data[3] ^ data[4] ^ data[6] ^ data[8] ^ data[12] ^ data[13] ^ data[14] ^ data[16] ^ data[18] ^ data[19] ^ data[23] ^ data[26] ^ data[30]
    ret[11] = crcIn[1] ^ crcIn[2] ^ crcIn[3] ^ crcIn[7] ^ crcIn[8] ^ crcIn[12] ^ crcIn[13] ^ data[0] ^ data[1] ^ data[3] ^ data[6] ^ data[7] ^ data[10] ^ data[11] ^ data[12] ^ data[15] ^ data[17] ^ data[18] ^ data[19] ^ data[23] ^ data[24] ^ data[28] ^ data[29]
    ret[12] = crcIn[0] ^ crcIn[3] ^ crcIn[7] ^ crcIn[8] ^ crcIn[9] ^ crcIn[11] ^ crcIn[12] ^ crcIn[14] ^ crcIn[15] ^ data[0] ^ data[1] ^ data[2] ^ data[5] ^ data[6] ^ data[7] ^ data[8] ^ data[9] ^ data[10] ^ data[14] ^ data[16] ^ data[19] ^ data[23] ^ data[24] ^ data[25] ^ data[27] ^ data[28] ^ data[30] ^ data[31]
    ret[13] = crcIn[1] ^ crcIn[4] ^ crcIn[8] ^ crcIn[9] ^ crcIn[10] ^ crcIn[12] ^ crcIn[13] ^ crcIn[15] ^ data[1] ^ data[2] ^ data[3] ^ data[6] ^ data[7] ^ data[8] ^ data[9] ^ data[10] ^ data[11] ^ data[15] ^ data[17] ^ data[20] ^ data[24] ^ data[25] ^ data[26] ^ data[28] ^ data[29] ^ data[31]
    ret[14] = crcIn[0] ^ crcIn[2] ^ crcIn[5] ^ crcIn[9] ^ crcIn[10] ^ crcIn[11] ^ crcIn[13] ^ crcIn[14] ^ data[2] ^ data[3] ^ data[4] ^ data[7] ^ data[8] ^ data[9] ^ data[10] ^ data[11] ^ data[12] ^ data[16] ^ data[18] ^ data[21] ^ data[25] ^ data[26] ^ data[27] ^ data[29] ^ data[30]
    ret[15] = crcIn[1] ^ crcIn[3] ^ crcIn[6] ^ crcIn[10] ^ crcIn[11] ^ crcIn[12] ^ crcIn[14] ^ crcIn[15] ^ data[3] ^ data[4] ^ data[5] ^ data[8] ^ data[9] ^ data[10] ^ data[11] ^ data[12] ^ data[13] ^ data[17] ^ data[19] ^ data[22] ^ data[26] ^ data[27] ^ data[28] ^ data[30] ^ data[31]
    return ret.x

def crc32(msg, poly=0x04C11DB7):
    crc = 0xffffffff
    for b in msg:
        crc ^= b
        for _ in range(8):
            crc = (crc >> 1) ^ poly if crc & 1 else crc >> 1
    return crc ^ 0xffffffff

@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    #id_count = 2**len(tb.source.bus.tid)
    idle_inserter = [None, cycle_pause]
    backpressure_inserter = [None, cycle_pause]

    cur_id = 1
    seq_num = 0x02

    await tb.reset()

    tb.set_idle_generator(None)
    tb.set_backpressure_generator(None)
    
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    # dut.tx_fc_ph.value = 0x16
    # dut.tx_fc_pd.value = 0xF40
    # dut.tx_fc_nph.value = 0x016
    # dut.tx_fc_npd.value = 0xF40
    #dut.retry_available.value = 1
    # dut.ack_nack.value = 1
    # dut.ack_nack_vld.value = 0
    dut.link_status.value = 0x2
    await RisingEdge(dut.clk)
    
    
    length = random.randint(1, 32)
    test_dllp = Dllp()
    test_dllp.type = DllpType.INIT_FC1_P
    test_dllp.seq = 0
    test_dllp.vc = 0
    test_dllp.hdr_scale = FcScale(0)
    test_dllp.hdr_fc = 1
    test_dllp.data_scale = FcScale(0)
    test_dllp.data_fc = 256
    test_dllp.feature_support = 0
    test_dllp.feature_ack = False
    #test_dllp.create_ack(2)
    #test_dllp.pack_crc()
    
    config = Configuration(
        width=16,
        polynomial=0x1DB7,
        init_value=0xFFFF,
        final_xor_value=0x00000000,
        reverse_input=False,
        reverse_output=True,
    )

    calculator = Calculator(config)
    
    data = test_dllp.pack()
    data += calculator.checksum(data).to_bytes(2, 'big')
    test_frame = AxiStreamFrame(data)
    print(data)
    
    
    await tb.source.send(test_frame)
    for i in range(20):
         await RisingEdge(dut.clk)
         
    test_dllp = Dllp()
    test_dllp.type = DllpType.INIT_FC1_NP
    test_dllp.seq = 0
    test_dllp.vc = 0
    test_dllp.hdr_scale = FcScale(0)
    test_dllp.hdr_fc = 1
    test_dllp.data_scale = FcScale(0)
    test_dllp.data_fc = 256
    test_dllp.feature_support = 0
    test_dllp.feature_ack = False
    data = test_dllp.pack()
    data += calculator.checksum(data).to_bytes(2, 'big')
    test_frame = AxiStreamFrame(data)
    await tb.source.send(test_frame)
    
    for i in range(20):
         await RisingEdge(dut.clk)
         
         
    test_dllp = Dllp()
    test_dllp.type = DllpType.INIT_FC1_CPL
    test_dllp.seq = 0
    test_dllp.vc = 0
    test_dllp.hdr_scale = FcScale(0)
    test_dllp.hdr_fc = 1
    test_dllp.data_scale = FcScale(0)
    test_dllp.data_fc = 256
    test_dllp.feature_support = 0
    test_dllp.feature_ack = False
    data = test_dllp.pack()
    data += calculator.checksum(data).to_bytes(2, 'big')
    test_frame = AxiStreamFrame(data)
    await tb.source.send(test_frame)
    
    for i in range(20):
         await RisingEdge(dut.clk)
         
         
    test_dllp = Dllp()
    test_dllp.type = DllpType.INIT_FC2_P
    test_dllp.seq = 0
    test_dllp.vc = 0
    test_dllp.hdr_scale = FcScale(0)
    test_dllp.hdr_fc = 1
    test_dllp.data_scale = FcScale(0)
    test_dllp.data_fc = 256
    test_dllp.feature_support = 0
    test_dllp.feature_ack = False
    data = test_dllp.pack()
    data += calculator.checksum(data).to_bytes(2, 'big')
    test_frame = AxiStreamFrame(data)
    await tb.source.send(test_frame)
    
    for i in range(20):
         await RisingEdge(dut.clk)
        
    await RisingEdge(dut.clk)    
    
    test_dllp = Dllp()
    test_dllp.type = DllpType.INIT_FC2_NP
    test_dllp.seq = 0
    test_dllp.vc = 0
    test_dllp.hdr_scale = FcScale(0)
    test_dllp.hdr_fc = 1
    test_dllp.data_scale = FcScale(0)
    test_dllp.data_fc = 256
    test_dllp.feature_support = 0
    test_dllp.feature_ack = False
    data = test_dllp.pack()
    data += calculator.checksum(data).to_bytes(2, 'big')
    test_frame = AxiStreamFrame(data)
    await tb.source.send(test_frame)
    
    for i in range(20):
         await RisingEdge(dut.clk)
         
    test_dllp = Dllp()
    test_dllp.type = DllpType.INIT_FC2_CPL
    test_dllp.seq = 0
    test_dllp.vc = 0
    test_dllp.hdr_scale = FcScale(0)
    test_dllp.hdr_fc = 1
    test_dllp.data_scale = FcScale(0)
    test_dllp.data_fc = 256
    test_dllp.feature_support = 0
    test_dllp.feature_ack = False
    data = test_dllp.pack()
    data += calculator.checksum(data).to_bytes(2, 'big')
    test_frame = AxiStreamFrame(data)
    await tb.source.send(test_frame)
    
    for i in range(20):
         await RisingEdge(dut.clk)
         
    test_dllp = Dllp()
    test_dllp = test_dllp.create_ack(0x002)
    data = test_dllp.pack()
    data += calculator.checksum(data).to_bytes(2, 'big')
    test_frame = AxiStreamFrame(data)
    await tb.source.send(test_frame)
    
    for i in range(20):
         await RisingEdge(dut.clk)
    # dut.ack_seq_num.value = 0x30
    # dut.ack_nack_vld.value = 1
    # await RisingEdge(dut.clk)
    # dut.ack_nack_vld.value = 0
    # for i in range(20):
    #     await RisingEdge(dut.clk)
    # data_in = await tb.sink.recv()