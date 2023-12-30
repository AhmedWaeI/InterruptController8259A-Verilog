Control_Logic (
	input		wire					clock,
	input		wire					reset,
	input		wire	[2:0]			cascade_in,
	output	reg	[2:0]			cascade_out,
	output	wire					cascade_io,
	input		wire					slave_program_n,
	output	wire					slave_program_or_enable_buffer,
	input		wire					interrupt_acknowledge_n,
	output	reg					interrupt_to_cpu,
	input		wire	[7:0]			internal_data_bus,
	input		wire					write_initial_command_word_1,
	input		wire					write_initial_command_word_2_4,
	input		wire					write_operation_control_word_1,
	input		wire					write_operation_control_word_2,
	input		wire					write_operation_control_word_3,
	input		wire					read,
	output	reg					out_control_logic_data,
	output	reg	[7:0]			control_logic_data,
	output	reg					level_or_edge_toriggered_config,
	//output	reg					special_fully_nest_config,
	output	reg					enable_read_register,
	output	reg					read_register_isr_or_irr,
	input		wire	[7:0]			interrupt,
	input		wire	[7:0]			highest_level_in_service,
	output	reg	[7:0]			interrupt_mask,
	//output	reg	[7:0]			interrupt_special_mask,
	output	reg	[7:0]			end_of_interrupt,
	output	reg	[2:0]			priority_rotate,
	output	reg					freeze,
	output	reg					latch_in_service,
	output	reg	[7:0]			clear_interrupt_request
	);

	reg [10:0] interrupt_vector_address;
	reg call_address_interval_4_or_8_config;
	reg single_or_cascade_config;
	reg set_icw4_config;
	reg [7:0] cascade_device_config;
	reg buffered_mode_config;
	reg buffered_master_or_slave_config;
	reg auto_eoi_config;
	//reg u8086_or_mcs80_config;
	reg special_mask_mode;
	reg enable_special_mask_mode;
	reg auto_rotate_mode;
	reg [7:0] acknowledge_interrupt;
	reg cascade_slave;
	reg cascade_slave_enable;
	reg cascade_output_ack_2_3;
	reg [31:0] command_state;
	reg [31:0] next_command_state;
  
	always @(*)
		if (write_initial_command_word_1 == 1'b1)
			next_command_state = 32'd1;
		else if (write_initial_command_word_2_4 == 1'b1)
			case (command_state)
				32'd1:
					if (single_or_cascade_config == 1'b0)
						next_command_state = 32'd2;
					else if (set_icw4_config == 1'b1)
						next_command_state = 32'd3;
					else
						next_command_state = 32'd0;
				32'd2:
					if (set_icw4_config == 1'b1)
						next_command_state = 32'd3;
					else
						next_command_state = 32'd0;
				32'd3: next_command_state = 32'd0;
				default: next_command_state = 32'd0;
			endcase
		else
			next_command_state = command_state;
  
  always @(*)
	wire write_initial_command_word_2 = (command_state == 32'd1) & write_initial_command_word_2_4;
	wire write_initial_command_word_3 = (command_state == 32'd2) & write_initial_command_word_2_4;
	wire write_initial_command_word_4 = (command_state == 32'd3) & write_initial_command_word_2_4;
	wire write_operation_control_word_1_registers = (command_state == 32'd0) & write_operation_control_word_1;
	wire write_operation_control_word_2_registers = (command_state == 32'd0) & write_operation_control_word_2;
	wire write_operation_control_word_3_registers = (command_state == 32'd0) & write_operation_control_word_3;
	reg [31:0] next_control_state;
	reg [31:0] control_state;
	reg prev_interrupt_acknowledge_n;
  
  always @(*)
			prev_interrupt_acknowledge_n <= interrupt_acknowledge_n;
	wire nedge_interrupt_acknowledge = prev_interrupt_acknowledge_n & ~interrupt_acknowledge_n;
	wire pedge_interrupt_acknowledge = ~prev_interrupt_acknowledge_n & interrupt_acknowledge_n;
	reg prev_read_signal;
  always @(*)
	wire nedge_read_signal = prev_read_signal & ~read;
	always @(*)
		case (control_state)
			32'd0:
				if ((write_operation_control_word_3_registers == 1'b1) && (internal_data_bus[2] == 1'b1))
					next_control_state = 32'd4;
				else if (write_operation_control_word_2_registers == 1'b1)
					next_control_state = 32'd0;
				else if (nedge_interrupt_acknowledge == 1'b0)
					next_control_state = 32'd0;
				else
					next_control_state = 32'd1;
			32'd1:
				if (pedge_interrupt_acknowledge == 1'b0)
					next_control_state = 32'd1;
				else
					next_control_state = 32'd2;
			32'd2:
				if (pedge_interrupt_acknowledge == 1'b0)
					next_control_state = 32'd2;
				else
					next_control_state = 32'd0;
			32'd3:
				if (pedge_interrupt_acknowledge == 1'b0)
					next_control_state = 32'd3;
				else
					next_control_state = 32'd0;
			32'd4:
				if (nedge_read_signal == 1'b0)
					next_control_state = 32'd4;
				else
					next_control_state = 32'd0;
			default: next_control_state = 32'd0;
		endcase

  
  always @(*)
			control_state <= next_control_state;
  
	always @(*)
		if ((control_state == 32'd0) && (next_control_state == 32'd4))
			latch_in_service = 1'b1;
		else if (cascade_slave == 1'b0)
			latch_in_service = (control_state == 32'd0) & (next_control_state != 32'd0);
		else
			latch_in_service = ((control_state == 32'd2) & (cascade_slave_enable == 1'b1)) & (nedge_interrupt_acknowledge == 1'b1);
  
	wire end_of_acknowledge_sequence = ((control_state != 32'd4) & (control_state != 32'd0)) & (next_control_state == 32'd0);
	wire end_of_poll_command = ((control_state == 32'd4) & (control_state != 32'd0)) & (next_control_state == 32'd0);
  
  always @(*)
		if (write_initial_command_word_1 == 1'b1)
			interrupt_vector_address[2:0] <= internal_data_bus[7:5];
		else
			interrupt_vector_address[2:0] <= interrupt_vector_address[2:0];

  
  always @(*)
		if (write_initial_command_word_1 == 1'b1)
			level_or_edge_toriggered_config <= internal_data_bus[3];
		else
			level_or_edge_toriggered_config <= level_or_edge_toriggered_config;
  
  always @(*)
		if (write_initial_command_word_1 == 1'b1)
			call_address_interval_4_or_8_config <= internal_data_bus[2];
		else
			call_address_interval_4_or_8_config <= call_address_interval_4_or_8_config;
  
  always @(*)
		if (write_initial_command_word_1 == 1'b1)
			single_or_cascade_config <= internal_data_bus[1];
		else
			single_or_cascade_config <= single_or_cascade_config;
  
  always @(*)
		if (write_initial_command_word_1 == 1'b1)
			set_icw4_config <= internal_data_bus[0];
		else
			set_icw4_config <= set_icw4_config;
  
  always @(*)
		if (write_initial_command_word_2 == 1'b1)
			interrupt_vector_address[10:3] <= internal_data_bus;
		else
			interrupt_vector_address[10:3] <= interrupt_vector_address[10:3];
  
  always @(*)
		if (write_initial_command_word_3 == 1'b1)
			cascade_device_config <= internal_data_bus;
		else
			cascade_device_config <= cascade_device_config;
  
  always @(*)//-------------might delete later-------------------
	if (write_initial_command_word_4 == 1'b1)
			buffered_mode_config <= internal_data_bus[3];
		else
			buffered_mode_config <= buffered_mode_config;
	assign slave_program_or_enable_buffer = ~buffered_mode_config;

  
  always @(*)
		if (write_initial_command_word_4 == 1'b1)
			auto_eoi_config <= internal_data_bus[1];
		else
			auto_eoi_config <= auto_eoi_config;

  
  always @(*)
		if ((write_operation_control_word_1_registers == 1'b1) && (enable_special_mask_mode == 1'b0))
			interrupt_mask <= internal_data_bus;
		else
			interrupt_mask <= interrupt_mask;

  
	always @(*)
		if ((auto_eoi_config == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
			end_of_interrupt = acknowledge_interrupt;
  else if (write_operation_control_word_2 == 1'b1) begin
			case(internal_data_bus[6:5])
				2'b01: end_of_interrupt = highest_level_in_service;
        2'b11:if(internal_data_bus[2:0]==3'b000) end_of_interrupt= 8'b00000001;
        else if(internal_data_bus[2:0]==3'b001) end_of_interrupt= 8'b00000010;
        else if(internal_data_bus[2:0]==3'b010) end_of_interrupt= 8'b00000100;
        else if(internal_data_bus[2:0]==3'b011) end_of_interrupt= 8'b00001000;
        else if(internal_data_bus[2:0]==3'b100) end_of_interrupt= 8'b00010000;
        else if(internal_data_bus[2:0]==3'b101) end_of_interrupt= 8'b00100000;
        else if(internal_data_bus[2:0]==3'b110) end_of_interrupt= 8'b01000000; 
        else if(internal_data_bus[2:0]==3'b111) end_of_interrupt= 8'b10000000;
      endcase
  end
		else
			end_of_interrupt = 8'b00000000;

  
  always @(*)
		if (write_operation_control_word_2 == 1'b1)
			case (internal_data_bus[7:5])
				3'b000: auto_rotate_mode <= 1'b0;
				3'b100: auto_rotate_mode <= 1'b1;
				default: auto_rotate_mode <= auto_rotate_mode;
			endcase
		else
			auto_rotate_mode <= auto_rotate_mode;

  
  always @(*)
		if ((auto_rotate_mode == 1'b1) && (end_of_acknowledge_sequence == 1'b1))
			priority_rotate <= KF8259_Common_Package_bit2num(acknowledge_interrupt);
		else if (write_operation_control_word_2 == 1'b1)
			case (internal_data_bus[7:5])
        3'b101:if(highest_level_in_service[0]==1'b1) priority_rotate <=3'b000;
        else if(highest_level_in_service[1]==1'b1) priority_rotate <=3'b001;
        else if(highest_level_in_service[2]==1'b1) priority_rotate <=3'b010;
        else if(highest_level_in_service[3]==1'b1) priority_rotate <=3'b011;
        else if(highest_level_in_service[4]==1'b1) priority_rotate <=3'b100;
        else if(highest_level_in_service[5]==1'b1) priority_rotate <=3'b101;
        else if(highest_level_in_service[6]==1'b1) priority_rotate <=3'b110;
        else if(highest_level_in_service[7]==1'b1) priority_rotate <=3'b111;
				3'b11z: priority_rotate <= internal_data_bus[2:0];
				default: priority_rotate <= priority_rotate;
			endcase
		else
			priority_rotate <= priority_rotate;

	
  always @(*)
	 if (write_operation_control_word_3_registers == 1'b1) begin
			enable_read_register <= internal_data_bus[1];
			read_register_isr_or_irr <= internal_data_bus[0];
		end
		else begin
			enable_read_register <= enable_read_register;
			read_register_isr_or_irr <= read_register_isr_or_irr;
		end

  
	always @(*)
		if (single_or_cascade_config == 1'b1)
			cascade_slave = 1'b0;
		else if (buffered_mode_config == 1'b0)
			cascade_slave = ~slave_program_n;
		else
			cascade_slave = ~buffered_master_or_slave_config;
	assign cascade_io = cascade_slave;

  
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
			if(acknowledge_interrupt[0]==1'b1) priority_rotate <=3'b000;
		        else if(acknowledge_interrupt[1]==1'b1) cascade_out <=3'b001;
		        else if(acknowledge_interrupt[2]==1'b1) cascade_out <=3'b010;
		        else if(acknowledge_interrupt[3]==1'b1) cascade_out <=3'b011;
		        else if(acknowledge_interrupt[4]==1'b1) cascade_out <=3'b100;
		        else if(acknowledge_interrupt[5]==1'b1) cascade_out <=3'b101;
		        else if(acknowledge_interrupt[6]==1'b1) cascade_out <=3'b110;
		        else if(acknowledge_interrupt[7]==1'b1) cascade_out <=3'b111;

	
	always @(*)
		if (interrupt != 8'b00000000)
			interrupt_to_cpu <= 1'b1;
		else if (end_of_acknowledge_sequence == 1'b1)
			interrupt_to_cpu <= 1'b0;
		else if (end_of_poll_command == 1'b1)
			interrupt_to_cpu <= 1'b0;
		else
			interrupt_to_cpu <= interrupt_to_cpu;

	
	always @(*)
		if (next_control_state == 32'd0)
			freeze <= 1'b0;
		else
			freeze <= 1'b1;

  
	always @(*)
		if (write_initial_command_word_1 == 1'b1)
			clear_interrupt_request = 8'b11111111;
		else if (latch_in_service == 1'b0)
			clear_interrupt_request = 8'b00000000;
		else
			clear_interrupt_request = interrupt;

	
	always @(*)
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
	always @(*)
		if (control_state == 32'd1)
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
							if(interrupt_when_ack1[0]==1'b1) control_logic_data[2:0]=3'b000;
							else if(interrupt_when_ack1[1]==1'b1) control_logic_data[2:0]=3'b001;
							else if(interrupt_when_ack1[2]==1'b1) control_logic_data[2:0]=3'b010;
							else if(interrupt_when_ack1[3]==1'b1) control_logic_data[2:0]=3'b011;
							else if(interrupt_when_ack1[4]==1'b1) control_logic_data[2:0]=3'b100;
							else if(interrupt_when_ack1[5]==1'b1) control_logic_data[2:0]=3'b101;
							else if(interrupt_when_ack1[6]==1'b1) control_logic_data[2:0]=3'b110;
							else if(interrupt_when_ack1[7]==1'b1) control_logic_data[2:0]=3'b111;
						else
							if(acknowledge_interrupt[0]==1'b1) control_logic_data[2:0]=3'b000;
							else if(acknowledge_interrupt[1]==1'b1) control_logic_data[2:0]=3'b001;
							else if(acknowledge_interrupt[2]==1'b1) control_logic_data[2:0]=3'b010;
							else if(acknowledge_interrupt[3]==1'b1) control_logic_data[2:0]=3'b011;
							else if(acknowledge_interrupt[4]==1'b1) control_logic_data[2:0]=3'b100;
							else if(acknowledge_interrupt[5]==1'b1) control_logic_data[2:0]=3'b101;
							else if(acknowledge_interrupt[6]==1'b1) control_logic_data[2:0]=3'b110;
							else if(acknowledge_interrupt[7]==1'b1) control_logic_data[2:0]=3'b111;
							
				
							if (call_address_interval_4_or_8_config == 1'b0)
								control_logic_data = {interrupt_vector_address[2:1], control_logic_data[2:0], 3'b000};
							else
								control_logic_data = {interrupt_vector_address[2:0], control_logic_data[2:0], 2'b00};
						
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
				if(acknowledge_interrupt[0]==1'b1) control_logic_data[2:0]=3'b000;
				else if(acknowledge_interrupt[1]==1'b1) control_logic_data[2:0]=3'b001;
				else if(acknowledge_interrupt[2]==1'b1) control_logic_data[2:0]=3'b010;
				else if(acknowledge_interrupt[3]==1'b1) control_logic_data[2:0]=3'b011;
				else if(acknowledge_interrupt[4]==1'b1) control_logic_data[2:0]=3'b100;
				else if(acknowledge_interrupt[5]==1'b1) control_logic_data[2:0]=3'b101;
				else if(acknowledge_interrupt[6]==1'b1) control_logic_data[2:0]=3'b110;
				else if(acknowledge_interrupt[7]==1'b1) control_logic_data[2:0]=3'b111;
			end
		end
		else begin
			out_control_logic_data = 1'b0;
			control_logic_data = 8'b00000000;
		end
endmodule
