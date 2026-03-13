/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Copyright 2025 Jiamu Sun <barroit@linux.com>
 * Copyright 2026 Jiamu Sun <39@barroit.sh>
 */

import { execlp } from '../lib/exec.js'

export function exec()
{
	execlp.call({ stdio: 'inherit' },
		    'debug=1 make', 'make', 'install', NULL)
}
