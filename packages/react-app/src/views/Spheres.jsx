import { useContractReader } from "eth-hooks";
import { ethers } from "ethers";
import React, {useState} from "react";
import { Link } from "react-router-dom";
import { Button, Col, Menu, Row, List, Card } from "antd";
import {
  Address,
  AddressInput
} from "../components";

/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 **/
function Spheres({ yourLocalBalance, readContracts, signer, loadWeb3Modal, tx, writeContracts, mainnetProvider, blockExplorer }) {
  // you can also use hooks locally in your component of choice
  // in this case, let's keep track of 'purpose' variable from our contract
  const Spheres = useContractReader(readContracts, "Sphere", "");

  const [transferToAddresses, setTransferToAddresses] = useState();
  const [address, setAddress] = useState();

  return (
    <div>
    <div style={{ maxWidth: 820, margin: "auto", marginTop: 32, paddingBottom: 32 }}>
              {signer?(
                <Button type={"primary"} onClick={()=>{
                  tx( writeContracts.Spheres.mintItem() )
                }}>MINT</Button>
              ):(
                <Button type={"primary"} onClick={loadWeb3Modal}>CONNECT WALLET</Button>
              )}

            </div>

            <div style={{ width: 820, margin: "auto", paddingBottom: 256 }}>
              <List
                bordered
                dataSource={Spheres}
                renderItem={item => {
                  const id = item.id.toNumber();

                  console.log("IMAGE",item.image); 
                  <List.Item key={id + "_" + item.uri + "_" + item.owner}>
                      <Card
                        title={
                          <div>
                            <span style={{ fontSize: 18, marginRight: 8 }}>{item.name}</span>
                          </div>
                        }
                      >
                        <a href={"https://opensea.io/assets/"+(readContracts && readContracts.Sphere && readContracts.Sphere.address)+"/"+item.id} target="_blank">
                        <img src={item.image} />
                        </a>
                        <div>{item.description}</div>
                      </Card>

                      <div>
                        owner:{" "}
                        <Address
                          address={item.owner}
                          ensProvider={mainnetProvider}
                          blockExplorer={blockExplorer}
                          fontSize={16}
                        />
                        <AddressInput
                          ensProvider={mainnetProvider}
                          placeholder="transfer to address"
                          value={transferToAddresses[id]}
                          onChange={newValue => {
                            const update = {};
                            update[id] = newValue;
                            setTransferToAddresses({ ...transferToAddresses, ...update });
                          }}
                        />
                        <Button
                          onClick={() => {
                            console.log("writeContracts", writeContracts);
                            tx(writeContracts.YourCollectible.transferFrom(address, transferToAddresses[id], id));
                          }}
                        >
                          Transfer
                        </Button>
                      </div>
                    </List.Item>
                }}
              /> 
              </div>
              </div>);  
}           


export default Spheres;
