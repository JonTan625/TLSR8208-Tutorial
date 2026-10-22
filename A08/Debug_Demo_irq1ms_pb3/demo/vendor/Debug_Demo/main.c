/********************************************************************************************************
 * @file    main.c
 *
 * @brief   This is the source file for Telink MCU
 *
 * @author  Driver Group
 * @date    2018
 *
 * @par     Copyright (c) 2018, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *
 *          Licensed under the Apache License, Version 2.0 (the "License");
 *          you may not use this file except in compliance with the License.
 *          You may obtain a copy of the License at
 *
 *              http://www.apache.org/licenses/LICENSE-2.0
 *
 *          Unless required by applicable law or agreed to in writing, software
 *          distributed under the License is distributed on an "AS IS" BASIS,
 *          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *          See the License for the specific language governing permissions and
 *          limitations under the License.
 *
 *******************************************************************************************************/
#include "app_config.h"
#include "calibration.h"


extern void user_init(void);
extern void main_loop (void);

/**
 * @brief		This function serves to handle the interrupt of MCU
 * @param[in] 	none
 * @return 		none
 */
volatile unsigned int timer0_irq_cnt = 0;	//A08 验证：1 ms 定时中断计数

_attribute_ram_code_sec_noinline_ void irq_handler(void)
{
	gpio_write(GPIO_PB3, 1);	//A08 验证：PB3 高 = CPU 在中断里
	if(timer_get_interrupt_status(TMR_STA_TMR0))
	{
		timer_clear_interrupt_status(TMR_STA_TMR0); //clear irq status
		timer0_irq_cnt ++;
	}
	gpio_write(GPIO_PB3, 0);

}

/**
 * @brief		This is main function
 * @param[in]	none
 * @return      none
 */
int main (void)   //must on ramcode
{
#if MIN_SYS
#if(MCU_CORE_TC122X)
	sys_init_min_sys();
#endif
#else
    PLATFORM_INIT;
    CLOCK_INIT;
#endif

	user_init();

	while (1) {
		main_loop ();
	}
	return 0;
}
