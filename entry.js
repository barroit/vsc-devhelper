/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 */

import { vsc_add_cmd } from './lib/vsc.js'

const cmds = {
	'make':            import('./cmd/make.js'),
	'reload-window':   import('./cmd/reload_window.js'),
	'reload-debugger': import('./cmd/reload_debugger.js'),
}

export async function activate(ctx)
{
	for (const id of Object.keys(cmds)) {
		const module = await cmds[id]
		const exec = vsc_add_cmd(`vscdev.${id}`, module.exec)

		ctx.subscriptions.push(exec)
	}
}
