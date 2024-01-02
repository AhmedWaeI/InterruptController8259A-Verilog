module pic8259A ( 

	input		wire					chip_select_n,
	input		wire					read_enable_n,
	input		wire					write_enable_n,
  input		wire	[7:0]				address,
	input		wire	[7:0]			data_bus_in,
	output	reg	[7:0]			data_bus_out,
	output	reg					data_bus_io,
	input		wire	[2:0]			cascade_in,
	output	wire	[2:0]			cascade_out,
	output	wire					cascade_io,
	input		wire					slave_program_n,
	output	wire					buffer_enable,
	output	wire					slave_program_or_enable_buffer,
	input		wire					interrupt_acknowledge_n,
	output	wire					interrupt_to_cpu,
	input		wire	[7:0]			interrupt_request
  
);
 wire [7:0] internal_data_bus;
wire write_initial_command_word_1;
wire write_initial_command_word_2;
wire write_initial_command_word_3;
wire write_initial_command_word_4;
wire write_operation_control_word_1;
wire write_operation_control_word_2;
wire write_operation_control_word_3;
wire read;
  Bus_Control_Logic bus(
  .CS_bar(chip_select_n),
		.RD_bar(read_enable_n),
		.WR_bar(write_enable_n),
    .A0(1'b0),
    
		.data_bus_buffer_out(address),
		.data_bus_buffer_in(data_bus_in),
		.internal_bus(internal_data_bus),
		.ICW_1(write_initial_command_word_1),
		.ICW_2(write_initial_command_word_2),
		.ICW_3(write_initial_command_word_3),
		.ICW_4(write_initial_command_word_4),
		.OCW_1(write_operation_control_word_1),
		.OCW_2(write_operation_control_word_2),
		.OCW_3(write_operation_control_word_3),
		.read(read)
  );
  wire out_control_logic_data;
	wire [7:0] control_logic_data;
	wire level_or_edge_toriggered_config;
	wire special_fully_nest_config;
	wire enable_read_register;
	wire read_register_isr_or_irr;
	wire [7:0] interrupt;
	wire [7:0] highest_level_in_service;
	wire [7:0] interrupt_mask;
	wire [7:0] interrupt_special_mask;
	wire [7:0] end_of_interrupt;
	wire [2:0] priority_rotate;
	wire freeze;
	wire latch_in_service;
	wire [7:0] clear_interrupt_request;
  	wire mode;
  Control_Logic  u_Control_Logic(
    .mode(mode),
		.casc_in(cascade_in),
		.casc_out(cascade_out),
		.casc_io(cascade_io),
		.slave_program_n(slave_program_n),
		.slave_program_or_enable_buffer(slave_program_or_enable_buffer),
		.interrupt_acknowledge_n(interrupt_acknowledge_n),
		.interrupt_to_cpu(interrupt_to_cpu),
		.internal_data_bus(internal_data_bus),
		.ICW_1(write_initial_command_word_1),
		.ICW_2_4(write_initial_command_word_2_4),
		.OCW_1(write_operation_control_word_1),
		.OCW_2(write_operation_control_word_2),
		.OCW_3(write_operation_control_word_3),
		.read(read),
		.out_control_logic_data(out_control_logic_data),
		.control_logic_data(control_logic_data),
		.level_or_edge_toriggered_config(level_or_edge_toriggered_config),
		.enable_read_register(enable_read_register),
		.read_register_isr_or_irr(read_register_isr_or_irr),
		.interrupt(interrupt),
		.highest_level_in_service(highest_level_in_service),
		.interrupt_mask(interrupt_mask),
		.end_of_interrupt(end_of_interrupt),
		.priority_rotate(priority_rotate),
		.freeze(freeze),
		.latch_in_service(latch_in_service),
    .clear_interrupt_request(clear_interrupt_request)
    
	);
  	wire [7:0] interrupt_request_register;
  Interrupt_Request IRR(
    .Level_OR_Edge_trigger(level_or_edge_toriggered_config),
    .Interrupt_Request_Pins(interrupt_request),
    .Interrupt_Request_Reg(interrupt_request_register)   );
  wire [7:0] in_service_register;
  PriorityResolver u_Priority_Resolver(
    .mode(mode),
    .interrupt_mask(interrupt_mask),
    .highest_level_in_service(highest_level_in_service),
    .interrupt_request_register(interrupt_request_register),
    .in_service_register(in_service_register),
    .interrupt(interrupt)
  );
    
  ISR inservice_reg(
    	.mode(mode),
    .modes_of_end_of_interrupt(data_bus_in[7:5]),
		.interrupt_special_mask(interrupt_special_mask),
		.highest_priority_interrupt(interrupt),
    .acknowledge(interrupt_to_cpu),
		.end_of_interrupt(end_of_interrupt),
    .specific_level_clear(data_bus_in[2:0]),
		.in_service_register(in_service_register),
    .last_serviced (highest_level_in_service));
    always @(*)
		if (out_control_logic_data == 1'b1) begin
			data_bus_io = 1'b0;
			data_bus_out = control_logic_data;
		end
		else if (read == 1'b0) begin
			data_bus_io = 1'b1;
			data_bus_out = 8'b00000000;
		end
		else if (address == 1'b1) begin
			data_bus_io = 1'b0;
			data_bus_out = interrupt_mask;
		end
		else if ((enable_read_register == 1'b1) && (read_register_isr_or_irr == 1'b0)) begin
			data_bus_io = 1'b0;
			data_bus_out = interrupt_request_register;
		end
		else if ((enable_read_register == 1'b1) && (read_register_isr_or_irr == 1'b1)) begin
			data_bus_io = 1'b0;
			data_bus_out = in_service_register;
		end
		else begin
			data_bus_io = 1'b1;
			data_bus_out = 8'b00000000;
		end
	assign buffer_enable = (slave_program_or_enable_buffer == 1'b1 ? 1'b0 : ~data_bus_io);
endmodule
