/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 * Copyright 2026 Jiamu Sun <39@barroit.sh>
 */

import { vsc_exec_cmd } from '../lib/vsc.js'

export async function exec()
{
	await vsc_exec_cmd('vscdev.make')
	vsc_exec_cmd('workbench.action.debug.restart')
}
