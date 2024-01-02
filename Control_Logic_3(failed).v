module Control_Logic_2 (

  //--------for cascade buffer/comparator---------------------
  input wire[2:0]     cascade_in,
  output  reg [2:0]     cascade_out,
  output  wire          cascade_io,

  //------------slave or buffer---------------------------
  input wire          slave_program_n,
  output  wire          slave_program_or_enable_buffer,

  //------INTA & INT-------------------------------------
  input   wire        interrupt_acknowledge_n,
  output  reg         interrupt_to_cpu,

  //---------from data bus buffer-------------------------
  input   wire  [7:0]     internal_data_bus,

  //--------from read/write control logic-------------------------
  input   wire          write_initial_command_word_1,
  input   wire          write_initial_command_word_2,
  input   wire          write_initial_command_word_3,
  input   wire          write_initial_command_word_4,
  input   wire          write_operation_control_word_1,
  input   wire          write_operation_control_word_2,
  input   wire          write_operation_control_word_3,
  input   wire          read,

  
  output  reg         out_control_logic_data,
  output  reg [7:0]     control_logic_data,
  output  reg         level_or_edge_toriggered_config,
  output  reg         special_fully_nest_config,
  output  reg         enable_read_register,
  output  reg         read_register_isr_or_irr,
  input   wire  [7:0]     interrupt,
  input   wire  [7:0]     highest_level_in_service,
  output  reg [7:0]     interrupt_mask,

  output  reg [7:0]     end_of_interrupt,
  output  reg [2:0]     priority_rotate,
  
  output  reg         latch_in_service,
  output  reg [7:0]     clear_interrupt_request
  );

  reg [10:0] interrupt_vector_address;
  reg call_address_interval_4_or_8_config;
  reg single_or_cascade_config;
  reg set_icw4_config;
  reg [7:0] cascade_device_config;
  reg buffered_mode_config;
  reg buffered_master_or_slave_config;
  reg auto_eoi_config;
  reg auto_rotate_mode;
  reg [7:0] acknowledge_interrupt;
  reg cascade_slave;
  reg cascade_slave_enable;
  reg cascade_output_ack_2_3;
  reg [7:0] command_state;

  
//----------------------------------------------------      
  always @(write_initial_command_word_1)begin  //handle edge& level trigger || interval 4/8
  
     if (write_initial_command_word_1 == 1'b1)begin
      single_or_cascade_config <= internal_data_bus[1];
      level_or_edge_toriggered_config <= internal_data_bus[3];
      call_address_interval_4_or_8_config <= internal_data_bus[2];
      set_icw4_config <= internal_data_bus[0];
      end
    /*else begin
      level_or_edge_toriggered_config <= level_or_edge_toriggered_config;
      call_address_interval_4_or_8_config <= call_address_interval_4_or_8_config;
          single_or_cascade_config <= single_or_cascade_config;
        set_icw4_config <= set_icw4_config;
    end*/
  end

  always @(set_icw4_config)begin
   if(set_icw4_config == 1'd1)begin
     if (write_initial_command_word_4 == 1'b1)begin
      auto_eoi_config <= internal_data_bus[1];
    end 
    else begin
      auto_eoi_config <= auto_eoi_config;
    end
   end
   /*
   else begin
      auto_eoi_config <= auto_eoi_config;
    end
    */
  end 
      
  always @(write_initial_command_word_2) //icw2 8086 mode address
    
     if (write_initial_command_word_2 == 1'b1)
      interrupt_vector_address[7:3] <= internal_data_bus;
    else
      interrupt_vector_address[7:3] <= interrupt_vector_address[7:3];
      
  always @(single_or_cascade_config) begin // if single=1 do not read ICW3 else read it (cascade)
   if(single_or_cascade_config==1'd0)begin  //Magdy
     if (write_initial_command_word_3 == 1'b1)begin
      cascade_device_config <= internal_data_bus;
      end
      else begin
      cascade_device_config <= cascade_device_config;
      end
   end 
   /*else begin
      cascade_device_config <= cascade_device_config;
   end*/
  end
      

  
  always @(write_operation_control_word_1)  //IMR handler
    begin
      if (write_operation_control_word_1_registers == 1'b1) begin
      interrupt_mask <= internal_data_bus;
    end
    
     end    
//------------------------------------------------------------------  

  always @(*) //priority 
    if ((auto_eoi_config == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
      end_of_interrupt = acknowledge_interrupt;
    else if (write_operation_control_word_2 == 1'b1)
      case (internal_data_bus[6:5])
        2'b01: end_of_interrupt = highest_level_in_service;
        2'b11: end_of_interrupt = internal_data_bus[2:0];//check b3deen.
        default: end_of_interrupt = 8'b00000000;
      endcase
    else
      end_of_interrupt = 8'b00000000;
  
     always @(write_operation_control_word_2)begin
       
        if (write_operation_control_word_2 == 1'b1)begin
           case (internal_data_bus[7:5])
                3'b000: auto_rotate_mode <= 1'b0;
                3'b100: auto_rotate_mode <= 1'b1;
                default: auto_rotate_mode <=1'b0;
              end
            end
          endcase
          /*always @(posedge clock or posedge reset)     ?????????????
    if (reset) begin
      enable_read_register <= 1'b1;
      read_register_isr_or_irr <= 1'b0;
    end
    else if (write_operation_control_word_3_registers == 1'b1) begin
      enable_read_register <= internal_data_bus[1];
      read_register_isr_or_irr <= internal_data_bus[0];
    end
    else begin
      enable_read_register <= enable_read_register;
      read_register_isr_or_irr <= read_register_isr_or_irr;
    end*/
    always(write_operation_control_word_3_registers)begin
      enable_read_register<=internal_data_bus[1];
      read_register_isr_or_irr<=internal_data_bus[0];
    end
  always @(*)
    if (single_or_cascade_config == 1'b1)
      cascade_slave = 1'b0;
    /*else if (buffered_mode_config == 1'b0)
      cascade_slave = ~slave_program_n;
    else
      cascade_slave = ~buffered_master_or_slave_config;*/
  assign cascade_io = cascade_slave;//check b3deen
  always @(*)
    if (cascade_slave == 1'b0)
      cascade_slave_enable = 1'b0;
    else if (cascade_device_config[2:0] != cascade_in)
      cascade_slave_enable = 1'b0;
    else
      cascade_slave_enable = 1'b1;
  wire interrupt_from_slave_device = (acknowledge_interrupt & cascade_device_config) != 8'b00000000;
  always @(*)
    if (single_or_cascade_config == 1'b1)
      cascade_output_ack_2_3 = 1'b1;
    else if (cascade_slave_enable == 1'b1)
      cascade_output_ack_2_3 = 1'b1;
    else if ((cascade_slave == 1'b0) && (interrupt_from_slave_device == 1'b0))
      cascade_output_ack_2_3 = 1'b1;
    else
      cascade_output_ack_2_3 = 1'b0;
  always @(*)
    if (cascade_slave == 1'b1)
      cascade_out <= 3'b000;
    else if (((control_state != 32'd1) && (control_state != 32'd2)) && (control_state != 32'd3))
      cascade_out <= 3'b000;
    else if (interrupt_from_slave_device == 1'b0)
      cascade_out <= 3'b000;
    else
      cascade_out <= KF8259_Common_Package_bit2num(acknowledge_interrupt);
  always @(posedge clock or posedge reset)
    if (reset)
      interrupt_to_cpu <= 1'b0;
    else if (interrupt != 8'b00000000)
      interrupt_to_cpu <= 1'b1;
    else if (end_of_acknowledge_sequence == 1'b1)
      interrupt_to_cpu <= 1'b0;
    else if (end_of_poll_command == 1'b1)
      interrupt_to_cpu <= 1'b0;
    else
      interrupt_to_cpu <= interrupt_to_cpu;
  
  always @(*)
    if (write_initial_command_word_1 == 1'b1)
      clear_interrupt_request = 8'b11111111;
    else if (latch_in_service == 1'b0)
      clear_interrupt_request = 8'b00000000;
    else
      clear_interrupt_request = interrupt;
  always @(posedge clock or posedge reset)
    if (reset)
      acknowledge_interrupt <= 8'b00000000;
    else if (end_of_acknowledge_sequence)
      acknowledge_interrupt <= 8'b00000000;
    else if (end_of_poll_command == 1'b1)
      acknowledge_interrupt <= 8'b00000000;
    else if (latch_in_service == 1'b1)
      acknowledge_interrupt <= interrupt;
    else
      acknowledge_interrupt <= acknowledge_interrupt;
  reg [7:0] interrupt_when_ack1;
  always @(posedge clock or posedge reset)
    if (reset)
      interrupt_when_ack1 <= 8'b00000000;
    else if (control_state == 32'd1)
      interrupt_when_ack1 <= interrupt;
    else
      interrupt_when_ack1 <= interrupt_when_ack1;
  always @(*)
    if (interrupt_acknowledge_n == 1'b0)
      case (control_state)
        32'd0:
          if (cascade_slave == 1'b0) begin
            if (u8086_or_mcs80_config == 1'b0) begin
              out_control_logic_data = 1'b1;
              control_logic_data = 8'b11001101;
            end
            else begin
              out_control_logic_data = 1'b0;
              control_logic_data = 8'b00000000;
            end
          end
          else begin
            out_control_logic_data = 1'b0;
            control_logic_data = 8'b00000000;
          end
        32'd1:
          if (cascade_slave == 1'b0) begin
            if (u8086_or_mcs80_config == 1'b0) begin
              out_control_logic_data = 1'b1;
              control_logic_data = 8'b11001101;
            end
            else begin
              out_control_logic_data = 1'b0;
              control_logic_data = 8'b00000000;
            end
          end
          else begin
            out_control_logic_data = 1'b0;
            control_logic_data = 8'b00000000;
          end
        32'd2:
          if (cascade_output_ack_2_3 == 1'b1) begin
            out_control_logic_data = 1'b1;
            if (cascade_slave == 1'b1)
              control_logic_data[2:0] = KF8259_Common_Package_bit2num(interrupt_when_ack1);
            else
              control_logic_data[2:0] = KF8259_Common_Package_bit2num(acknowledge_interrupt);
            if (u8086_or_mcs80_config == 1'b0) begin
              if (call_address_interval_4_or_8_config == 1'b0)
                control_logic_data = {interrupt_vector_address[2:1], control_logic_data[2:0], 3'b000};
              else
                control_logic_data = {interrupt_vector_address[2:0], control_logic_data[2:0], 2'b00};
            end
            else
              control_logic_data = {interrupt_vector_address[10:6], control_logic_data[2:0]};
          end
          else begin
            out_control_logic_data = 1'b0;
            control_logic_data = 8'b00000000;
          end
        32'd3:
          if (cascade_output_ack_2_3 == 1'b1) begin
            out_control_logic_data = 1'b1;
            control_logic_data = interrupt_vector_address[10:3];
          end
          else begin
            out_control_logic_data = 1'b0;
            control_logic_data = 8'b00000000;
          end
        default: begin
          out_control_logic_data = 1'b0;
          control_logic_data = 8'b00000000;
        end
      endcase
    else if ((control_state == 32'd4) && (read == 1'b1)) begin
      out_control_logic_data = 1'b1;
      if (acknowledge_interrupt == 8'b00000000)
        control_logic_data = 8'b00000000;
      else begin
        control_logic_data[7:3] = 5'b10000;
        control_logic_data[2:0] = KF8259_Common_Package_bit2num(acknowledge_interrupt);
      end
    end
    else begin
      out_control_logic_data = 1'b0;
      control_logic_data = 8'b00000000;
    end
endmodule
