# Check that the Solidity code compiles before pushing it to github
push:
	npx hardhat compile
	npx hardhat run scripts/sample-script.js
	git push
