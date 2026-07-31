--[[
  Wolfe's Mekanism Induction Matrix Monitor v2
  Usage: Put computer near an Induction Port and a monitor (2x3 array should work fine) and install. Optionally add a modem for wireless functionality (requires restart).
  Installation: pastebin run LMdUZY4Z install
  Configuration: Edit the "config" file, refer to the comments below for what each field means
 
  Wireless Usage: Doesn't require a Monitor on main PC, just a Modem, just make sure you add an identifier on config file.
  Wireless Receiver: Use script at https://pastebin.com/3naSaR8X
]]
 
-- Default settings, do not change
local options = {
  -- Unique identifier for this matrix on rednet, required for rednet functionality
  rednet_identifier = '',
 
  -- Energy type being displayed (J, FE)
  energy_type = 'FE',
 
  -- Update frequency, in seconds
  update_frequency = 1,
 
  -- Text scale on the monitor
  text_scale = 1,
 
  -- Output debug data to the computer's internal display
  debug = true,
}
 
--------------------------------------------------
--- Internal variables, DO NOT CHANGE
--------------------------------------------------
 
--- This will be used as the installer source (Pastebin)
local INSTALLER_ID = 'LMdUZY4Z'
 
--- Supported energy suffixes
local energy_suffixes = { 'k', 'M', 'G', 'T', 'P' }
 
--- Supported time periods when converting seconds
local time_periods = {
  { 'weeks', 604800 },
  { 'days', 86400 },
  { 'hours', 3600 },
  { 'minutes', 60 },
  { 'seconds', 1 },
}
 
--- This is our Induction Matrix, we'll auto-detect it later
local induction_matrix = nil
 
--- This is our Monitor, we'll auto-detect it later
local monitor = nil
 
--- This is our Modem, we'll auto-detect it later
local modem = nil
 
--- Prefix used for rednet channels
local rednet_prefix = 'WL_Mek_Matrix'
 
--------------------------------------------------
--- Helper functions
--------------------------------------------------
 
--- Reads a file's contents
---@return string
function file_read (file)
  local handle = fs.open(file, 'r')
  local data = handle.readAll()
  handle.close()
  return data
end
 
--- Writes data to a file (overrides existing data)
function file_write (file, data)
  local handle = fs.open(file, 'w')
  handle.write(data)
  handle.close()
end
 
--- Holds the current buffer of data being printed
local machine_term = term.current()
local print_buffer = {}
 
--- Writes data to the output monitor buffer
function print_r (text)
  table.insert(print_buffer, text)
end
 
--- Writes formatted data to the output monitor buffer
function print_f (format, ...)
  print_r(string.format(format, ...))
end
 
--- Writes the buffer into the output monitor
function print_flush ()
  if monitor then
    -- Redirects writes to monitor (if any)
    if monitor then
      term.redirect(monitor)
    end
 
    -- Clears terminal
    term.clear()
    term.setCursorPos(1, 1)
 
    -- Writes new data
    print(table.concat(print_buffer or {}, '\n'))
 
    -- Redirects writes back to computer (if using monitor)
    if monitor then
      term.redirect(machine_term)
    end
  end
 
  -- Clears buffer
  print_buffer = {}
end
 
--- Writes debug info to the machine
function debug (...)
  if options.debug then
    print(...)
  end
end
 
--- Rounds a number with N decimals
function round_decimal (number, decimals)
  local multiplier = math.pow(10, decimals or 0)
  return math.floor(number * multiplier) / multiplier
end
 
--- Rounds a percentage (0..1) to a number of decimals
function round_percentage (number, decimals)
  return ('%s%%'):format(round_decimal(100 * number, decimals or 1))
end
 
--- The current energy type
local energy_type = 'J'
 
--- Converts energy values
local energy_convert = function (energy) return energy end
if mekanismEnergyHelper and mekanismEnergyHelper[('joulesTo%s'):format(options.energy_type)] then
  energy_type = options.energy_type
  energy_convert = mekanismEnergyHelper[('joulesTo%s'):format(options.energy_type)]
end
 
--- Prints an energy value
local energy_string = function (energy, decimals)
  local prefix = ''
  local suffix = ''
 
  -- Prepares a prefix for negative numbers
  if energy < 0 then
    prefix = '-'
  end
 
  -- We need a positive number here for calculating multipliers (k, M, G, T), we'll add the minus later, we also convert it to the right unit
  local amount = energy_convert(math.abs(energy))
 
  -- Finds the proper suffix/multiplier
  for _, multiplier in pairs(energy_suffixes) do
    -- Stops when amount is less than 1000
    if amount < 1000 then
      break
    end
 
    -- Updates suffix and amount to new value
    amount = amount / 1000
    suffix = multiplier
  end
 
  -- Returns the formatted string
  return ('%s%s%s%s'):format(prefix, round_decimal(amount, decimals or 1), suffix, energy_type)
end
 
--- Generates an ETA string when given a number of seconds
function eta_string (seconds)
  -- Makes sure we're only dealing with integers
  seconds = math.floor(seconds)
 
  -- Processes time periods
  local time = {}
  for _, period in pairs(time_periods) do
    local count = math.floor(seconds / period[2])
    time[period[1]] = count
    seconds = seconds - (count * period[2])
  end
 
  -- If we have more than 72h worth of storage, switch to week, day, hour format
  if time.weeks > 0 then
    return ('%dwk %dd %dh'):format(time.weeks, time.days, time.hours)
  elseif time.days >= 3 then
    return ('%dd %dh'):format(time.days, time.hours)
  end
 
  -- For all other cases, we'll just use H:MM:SS
  return ('%d:%02d:%02d'):format(time.hours, time.minutes, time.seconds)
end
 
--- Prints the Induction Matrix information
function print_matrix_info (matrix_info)
  print_r('Ind.Matrix Monitor')
  print_r('------------------')
  print_r('')
  print_f('Power : %s', energy_string(matrix_info.energy_stored))
  print_f('Limit : %s', energy_string(matrix_info.energy_capacity))
  print_f('Charge: %s', round_percentage(matrix_info.energy_percentage))
  print_r('')
  print_f('Input : %s/t', energy_string(matrix_info.io_input))
  print_f('Output: %s/t', energy_string(matrix_info.io_output))
  print_f('Max IO: %s/t', energy_string(matrix_info.io_capacity))
  print_r('')
 
  -- If we have negative value here, we'll save a character by removing the space so it fits same line
  if matrix_info.change_amount < 0 then
    print_f('Change:%s/s', energy_string(matrix_info.change_amount_per_second))
  else
    print_f('Change: %s/s', energy_string(matrix_info.change_amount_per_second))
  end
 
  -- Charge/discharge status
  print_r('Status:')
  if matrix_info.is_charging then
    print_f('Charg. %s', eta_string((matrix_info.energy_capacity - matrix_info.energy_stored) / matrix_info.change_amount_per_second))
  elseif matrix_info.is_discharging then
    print_f('Disch. %s', eta_string(matrix_info.energy_stored / math.abs(matrix_info.change_amount_per_second)))
  else
    print_r('Idle')
  end
end
 
--------------------------------------------------
--- Program initialization
--------------------------------------------------
 
args = {...}
 
-- Loads custom options from filesystem
if fs.exists('config') then
  debug('Loading settings from "config" file...')
 
  -- Reads custom options
  local custom_options = textutils.unserialize(file_read('config'))
 
  -- Overrides each of the existing options
  for k, v in pairs(custom_options) do
    options[k] = v
  end
end
 
-- Writes back config file
print('Updating config file...')
file_write('config', textutils.serialize(options))
 
-- Handles special case when "install" is executed from the pastebin
if 'install' == args[1] then
  print('Installing Matrix Monitor...')
 
  -- Are we on first install? If so, we'll run open the config for editing later
  local has_existing_install = fs.exists('startup.lua')
 
  -- Removes existing version
  if fs.exists('startup.lua') then
    fs.delete('startup.lua')
  end
 
  -- Downloads script from Pastebin
  shell.run('pastebin', 'get', INSTALLER_ID, 'startup.lua')
 
  -- Runs config editor
  if not has_existing_install then
    print('Opening config file for editing...')
    sleep(2.5)
    shell.run('edit', 'config')
  end
 
  -- Reboots the computer after everything is done
  print('Install complete! Restarting computer...')
  sleep(2.5)
  os.reboot()
end
 
-- Detects peripherals
monitor = peripheral.find('monitor')
modem = peripheral.find('modem')
 
--- The rednet channel/protocol we'll be using
local rednet_channel = nil
 
-- Checks for an existing monitor
if monitor then
  debug('Monitor detected, enabling output!')
  monitor.setTextScale(options.text_scale)
else
  debug('No monitor detected, entering headless mode!')
 
  -- Makes sure we have a connected modem
  if not modem then
    error('No monitor or modem detected, cannot enter headless mode!')
  end
end
 
-- Conencts to rednet if modem available
if peripheral.find('modem') then
  if not options.rednet_identifier or options.rednet_identifier == '' then
    debug('Modem has been found, but no wireless identifier found on configs, will not connect!')
  else
    peripheral.find('modem', rednet.open)
    debug('Connected to rednet!')
    rednet_channel = ('%s#%s'):format(rednet_prefix, options.rednet_identifier)
  end
end
 
--------------------------------------------------
--- Main runtime
--------------------------------------------------
 
debug('Entering main loop...')
 
--- This will be updated after every energy collection, it is used to calculate how much power is actually being added/removed from the system
local energy_stored_previous = nil
 
while true do
  local status, err = pcall(function () 
    -- Attempts to auto-detect missing Induction Port
    if not induction_matrix then
      induction_matrix = peripheral.find('inductionPort')
 
      -- Checks if it worked
      if not induction_matrix then
        error('Induction Port not connected!')
      end
    end
 
    --- This is our main information
    local matrix_info = {
      energy_stored = induction_matrix.getEnergy(),
      energy_capacity = induction_matrix.getMaxEnergy(),
      energy_percentage = induction_matrix.getEnergyFilledPercentage(),
      io_input = induction_matrix.getLastInput(),
      io_output = induction_matrix.getLastOutput(),
      io_capacity = induction_matrix.getTransferCap(),
    }
 
    -- Detects power changes
    if not energy_stored_previous then
      energy_stored_previous = matrix_info.energy_stored
    end
 
    -- Calculates power changes and adds them to our information
    matrix_info.change_interval = options.update_frequency
    matrix_info.change_amount = matrix_info.energy_stored - energy_stored_previous
    matrix_info.change_amount_per_second = matrix_info.change_amount / options.update_frequency
 
    -- General stats
    matrix_info.is_charging = matrix_info.change_amount > 0
    matrix_info.is_discharging = matrix_info.change_amount < 0
 
    -- Sets the new "previous" value
    energy_stored_previous = matrix_info.energy_stored
 
    -- Broadcasts our matrix info if we have a modem
    if rednet.isOpen() and rednet_channel then
      rednet.broadcast(textutils.serialize(matrix_info), rednet_channel)
    end
 
    -- Prints the matrix information
    print_matrix_info(matrix_info)
  end)
 
  -- Checks for errors (might be disconnected)
  if not status then
    -- Clears buffer first
    print_buffer = {}
 
    -- Shows error message
    print_r('Error reading data')
    print_r('Check connections.')
    print_r('------------------')
    print_r(err)
  end
 
  -- Outputs text to screen
  print_flush()
 
  -- Waits for next cycle
  os.sleep(options.update_frequency)
end
