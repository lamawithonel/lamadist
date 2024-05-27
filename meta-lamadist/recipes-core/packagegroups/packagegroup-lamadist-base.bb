# SPDX-License-Identifier: Apache-2.0

DESCRIPTION = 'Base packagegroup'

LICENSE = 'Apache-2.0'

inherit packagegroup

RDEPENDS:${PN} = " \
    haveged \
"
