import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'

function readProjectFile(path: string) {
  return readFileSync(resolve(process.cwd(), path), 'utf8')
}

describe('ShipGlowz public installer', () => {
  test('serves the generated shell artifact instead of a duplicated template', () => {
    const route = readProjectFile('src/pages/shipglowz-script.ts')
    const installer = readProjectFile('src/generated/shipglowz-installer.sh')

    expect(route).toContain("import installer from '../generated/shipglowz-installer.sh?raw'")
    expect(route).not.toContain('const installer = `')
    expect(installer).toMatch(/^#!\/usr\/bin\/env sh/)
    expect(installer).toContain('SHIPGLOWZ_INSTALL_MODE')
    expect(installer).toContain('Mode d\'installation: $INSTALL_MODE')
    expect(installer).toContain('$SHIPGLOWZ_DIR/local/install.sh')
    expect(installer).toContain('$SHIPGLOWZ_DIR/cli/install.sh')
  })

  test('publishes one sudo-free interactive command in English and French', () => {
    const content = readProjectFile('src/data/scriptInstallPages.ts')
    const shipglowzSection = content.slice(content.indexOf('\tshipglowz: {'))
    const command = 'curl -fsSL https://www.winflowz.com/shipglowz-script | sh'

    expect(shipglowzSection.match(new RegExp(command.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'))).toHaveLength(2)
    expect(shipglowzSection).not.toContain('shipglowz-script | sudo sh')
    expect(shipglowzSection).toContain('SHIPGLOWZ_INSTALL_MODE=local sh')
    expect(shipglowzSection).toContain('SHIPGLOWZ_INSTALL_MODE=full sh')
    expect(shipglowzSection).toContain('private ShipGlowz repository')
    expect(shipglowzSection).toContain('dépôt privé ShipGlowz')
  })
})
