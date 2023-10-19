module dllp_handler
  import pcie_datalink_pkg::*;
#(
    // TLP data width
    parameter int DATA_WIDTH = 32,
    // TLP strobe width
    parameter int STRB_WIDTH = DATA_WIDTH / 8,
    parameter int KEEP_WIDTH = STRB_WIDTH,
    parameter int USER_WIDTH = 3,
    parameter int S_COUNT = 1,
    //
    parameter int RAM_DATA_WIDTH = 8,  // width of the data
    parameter int RAM_ADDR_WIDTH = 4   // number of address bits
) (
    input logic       clk_i,         // Clock signal
    input logic       rst_i,         // Reset signal
    input logic [1:0] link_status_i,


    /*
     * PHY AXIS inputs
     */
    input  logic [DATA_WIDTH-1:0] s_axis_tdata_i,
    input  logic [KEEP_WIDTH-1:0] s_axis_tkeep_i,
    input  logic [   S_COUNT-1:0] s_axis_tvalid_i,
    input  logic [   S_COUNT-1:0] s_axis_tlast_i,
    input  logic [USER_WIDTH-1:0] s_axis_tuser_i,
    output logic [   S_COUNT-1:0] s_axis_tready_o,

    //tlp ack/nak
    output logic [11:0] seq_num_o,
    output logic        seq_num_vld_o,
    output logic        seq_num_acknack_o,
    //flow control values
    output logic        fc1_values_stored_o,
    output logic        fc2_values_stored_o,

    /*
     * Flow control
     */
    output logic [ 7:0] tx_fc_ph_o,
    output logic [11:0] tx_fc_pd_o,
    output logic [ 7:0] tx_fc_nph_o,
    output logic [11:0] tx_fc_npd_o
);


  //tlp to dllp fsm emum
  typedef enum logic [2:0] {
    ST_IDLE,
    ST_CHECK_CRC,
    ST_PROCESS_DLLP,
    ST_DLL_RX_DATA,
    ST_TLP_EOP
  } dll_rx_st_e;

  dll_rx_st_e curr_state, next_state;
  dllp_union_t dll_packet_c, dll_packet_r;


  //crc helper signals
  logic [15:0] crc_in_c, crc_in_r;
  logic [15:0] crc_out;

  //tlp nulled
  logic tlp_nullified_c, tlp_nullified_r;
  logic tx_tlp_ready_c, tx_tlp_ready_r;

  //transmit sequence logic
  logic [15:0] next_transmit_seq_c, next_transmit_seq_r;
  logic [11:0] ackd_transmit_seq_c, ackd_transmit_seq_r;


  //Flow control
  logic [7:0] tx_fc_ph_c, tx_fc_ph_r;
  logic [11:0] tx_fc_pd_c, tx_fc_pd_r;
  logic [7:0] tx_fc_nph_c, tx_fc_nph_r;
  logic [11:0] tx_fc_npd_c, tx_fc_npd_r;
  logic [7:0] tx_fc_ch_c, tx_fc_ch_r;
  logic [11:0] tx_fc_cd_c, tx_fc_cd_r;

  //fc1 vals
  logic fc1_np_stored_c, fc1_np_stored_r;
  logic fc1_p_stored_c, fc1_p_stored_r;
  logic fc1_c_stored_c, fc1_c_stored_r;
  //fc2 vals
  logic fc2_np_stored_c, fc2_np_stored_r;
  logic fc2_p_stored_c, fc2_p_stored_r;
  logic fc2_c_stored_c, fc2_c_stored_r;

  assign fc1_values_stored_o = fc1_np_stored_r & fc1_p_stored_r & fc1_c_stored_r;
  assign fc2_values_stored_o = fc2_np_stored_r & fc2_p_stored_r & fc2_c_stored_r;


  always @(posedge clk_i or posedge rst_i) begin : main_seq
    if (rst_i) begin
      curr_state <= ST_IDLE;
      next_transmit_seq_r <= '0;
      dll_packet_r <= '0;
      //crc signals
      crc_in_r <= '0;
      //flow control
      tx_fc_ph_r <= '0;
      tx_fc_pd_r <= '0;
      tx_fc_nph_r <= '0;
      tx_fc_npd_r <= '0;
      tx_fc_ch_r <= '0;
      tx_fc_cd_r <= '0;
      //capture signals
      fc1_np_stored_r <= '0;
      fc1_p_stored_r <= '0;
      fc1_c_stored_r <= '0;
      fc2_np_stored_r <= '0;
      fc2_p_stored_r <= '0;
      fc2_c_stored_r <= '0;
    end else begin
      curr_state <= next_state;
      next_transmit_seq_r <= next_transmit_seq_c;
      dll_packet_r <= dll_packet_c;
      //crc signals
      crc_in_r <= crc_in_c;
      //flow control
      tx_fc_ph_r <= tx_fc_ph_c;
      tx_fc_pd_r <= tx_fc_pd_c;
      tx_fc_nph_r <= tx_fc_nph_c;
      tx_fc_npd_r <= tx_fc_npd_c;
      tx_fc_ch_r <= tx_fc_ch_c;
      tx_fc_cd_r <= tx_fc_cd_c;
      //capture signals
      fc1_np_stored_r <= fc1_np_stored_c;
      fc1_p_stored_r <= fc1_p_stored_c;
      fc1_c_stored_r <= fc1_c_stored_c;
      fc2_np_stored_r <= fc2_np_stored_c;
      fc2_p_stored_r <= fc2_p_stored_c;
      fc2_c_stored_r <= fc2_c_stored_c;
    end
  end


  always_comb begin : main_combo
    next_state          = curr_state;
    next_transmit_seq_c = next_transmit_seq_r;
    dll_packet_c        = dll_packet_r;
    s_axis_tready_o     = '0;
    //crc signals
    crc_in_c            = crc_in_r;
    //ack_nack signals
    seq_num_o           = '0;
    seq_num_vld_o       = '0;
    seq_num_acknack_o   = '0;
    //flow control
    tx_fc_ph_c          = tx_fc_ph_r;
    tx_fc_pd_c          = tx_fc_pd_r;
    tx_fc_nph_c         = tx_fc_nph_r;
    tx_fc_npd_c         = tx_fc_npd_r;
    tx_fc_ch_c          = tx_fc_ch_r;
    tx_fc_cd_c          = tx_fc_cd_r;


    //capture signals
    fc1_np_stored_c     = fc1_np_stored_r;
    fc1_p_stored_c      = fc1_p_stored_r;
    fc1_c_stored_c      = fc1_c_stored_r;
    fc2_np_stored_c     = fc2_np_stored_r;
    fc2_p_stored_c      = fc2_p_stored_r;
    fc2_c_stored_c      = fc2_c_stored_r;

    case (curr_state)
      ST_IDLE: begin
        if ((link_status_i == DL_ACTIVE)) begin
          s_axis_tready_o = '1;
          if (s_axis_tvalid_i) begin
            dll_packet_c = s_axis_tdata_i;
            crc_in_c = crc_out;
            next_state = ST_CHECK_CRC;
          end
        end
      end
      ST_CHECK_CRC: begin
        s_axis_tready_o = '1;
        if (s_axis_tvalid_i) begin
          if (crc_in_r == s_axis_tdata_i[15:0]) begin
            //process tlp
            next_state = ST_PROCESS_DLLP;
          end
        end
      end
      ST_PROCESS_DLLP: begin
        //process tlp
        casez (dll_packet_r.generic.dllp_type)
          Ack: begin
            seq_num_o = get_ack_nack_seq(dll_packet_r.ack_nack);
            seq_num_vld_o = '1;
            seq_num_acknack_o = '1;
          end
          Nak: begin
            seq_num_o = get_ack_nack_seq(dll_packet_r.ack_nack);
            seq_num_vld_o = '1;
          end
          PM_Enter_L1: begin
            //not implemented
          end
          PM_Enter_L23: begin
            //not implemented
          end
          PM_Actv_St_Req_L1: begin
            //not implemented
          end
          PM_Request_Ack: begin
            //not implemented
          end
          Vendor_Specific: begin
            //not implemented
          end
          InitFC1_P: begin
            tx_fc_ph_c = dll_packet_r.generic.header.hdr.HdrFC;
            tx_fc_pd_c = dll_packet_r.generic.seq_datafc.data_fc;
            fc1_p_stored_c = '1;
          end
          InitFC1_NP: begin
            tx_fc_nph_c = get_fc_hdr(dll_packet_r.flow_control);
            tx_fc_npd_c = get_fc_data(dll_packet_r.flow_control);
            fc1_np_stored_c = '1;
          end
          InitFC1_Cpl: begin
            //not implemented
            fc1_c_stored_c = '1;
          end
          InitFC2_P: begin
            tx_fc_ph_c = get_fc_hdr(dll_packet_r.flow_control);
            tx_fc_pd_c = get_fc_data(dll_packet_r.flow_control);
            fc2_p_stored_c = '1;
          end
          InitFC2_NP: begin
            tx_fc_nph_c = get_fc_hdr(dll_packet_r.flow_control);
            tx_fc_npd_c = get_fc_data(dll_packet_r.flow_control);
            fc2_np_stored_c = '1;
          end
          InitFC2_Cpl: begin
            //not implemented
            fc2_c_stored_c = '1;
          end
          UpdateFC_P: begin
            tx_fc_ph_c = get_fc_hdr(dll_packet_r.flow_control);
            tx_fc_pd_c = get_fc_data(dll_packet_r.flow_control);
          end
          UpdateFC_NP: begin
            tx_fc_nph_c = get_fc_hdr(dll_packet_r.flow_control);
            tx_fc_npd_c = get_fc_data(dll_packet_r.flow_control);
          end
          UpdateFC_Cpl: begin
          end
          default: begin
          end
        endcase
        next_state = ST_IDLE;
      end
      default: begin
      end
    endcase
  end

  pcie_datalink_crc pcie_datalink_crc_inst (
      .crcIn ('1),
      .data  (s_axis_tdata_i),
      .crcOut(crc_out)
  );



  assign tx_fc_ph_o  = tx_fc_ph_r;
  assign tx_fc_pd_o  = tx_fc_pd_r;
  assign tx_fc_nph_o = tx_fc_nph_r;
  assign tx_fc_npd_o = tx_fc_npd_r;


endmodule