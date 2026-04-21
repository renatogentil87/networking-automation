OSPF Lab Scenarios — 9 Router Topology

Fundamentals

    Configure a single Area 0 with all 9 routers and verify full adjacency — confirm all routers share an identical LSDB using show ip ospf database
    On a multi-access segment with R1, R2, and R3, manipulate OSPF priority to force R1 as DR, R2 as BDR, and R3 as DROTHER — verify with show ip ospf interface eth1
    Configure point-to-point network type between R4 and R5 — confirm no DR/BDR election occurs and compare adjacency behavior against the multi-access segment
    Intentionally mismatch hello/dead timers between R6 and R7 — observe the adjacency failure, fix it, and document the exact error in show ip ospf neighbor

Multi-Area

    Design a 4-area topology: Area 0 (R1, R2, R3), Area 1 (R4, R5), Area 2 (R6, R7), Area 3 (R8, R9) — configure R2 as ABR for Area 1, R3 as ABR for Area 2, and R1 as ABR for Area 3
    Verify routers in Area 1 receive LSA Type 1, 2, and 3 — confirm they do NOT receive LSA Type 1/2 originating from Area 2 or Area 3
    Configure Area 1 as a stub area — verify R4 and R5 no longer receive LSA Type 5 and instead receive a default Type 3 route from R2
    Convert Area 2 to a totally stubby area — verify R6 and R7 have only a single default route and zero Type 3 LSAs from other areas in their routing table
    Configure Area 3 as an NSSA — redistribute a static route into OSPF on R9 and verify R9 generates a Type 7 LSA, then confirm R1 (ABR) translates it to Type 5 into Area 0

Route Manipulation

    Redistribute 5 static routes into OSPF on R8 — verify all routers in Area 0 receive LSA Type 5 and confirm R8 appears as ASBR in show ip ospf database external
    Configure manual summarization on R2 (ABR) to aggregate all Area 1 prefixes into a single summary advertised into Area 0 — verify no component routes appear in Area 0
    Filter a specific Type 3 LSA at R3 (ABR) using area X filter-list so Area 2 routers never receive a specific Area 0 prefix — verify the filter with show ip route on R6
    Configure default-information originate always on R1 — verify all 8 routers receive a Type 5 default route, then remove always and observe the behavior difference
    Place R5 in a totally stubby area and verify its routing table contains only a default route — then ping an external prefix from R5 and trace the path

Authentication & Security

    Configure MD5 authentication on all Area 0 interfaces — intentionally set a wrong key on R3 and observe the adjacency drop, then fix it and verify recovery
    Configure per-interface plaintext authentication only on the R4–R5 link — verify Area 1 adjacency uses authentication while Area 0 links remain unauthenticated

Advanced & Troubleshooting

    Shut down the link between R1 and R2 to simulate an ABR failure — measure OSPF reconvergence time across all 9 routers and verify alternate paths are used via show ip ospf neighbor and traceroute
    Create a virtual link between R2 and R3 through Area 1 to provide a redundant backbone connection — verify LSA Type 3 flows correctly and the virtual link appears in show ip ospf virtual-links
    Manipulate OSPF cost on R4, R5, and R6 to engineer a specific traffic path from R9 to R1 — verify asymmetric routing exists using traceroute from both ends and document the cost calculation
    Redistribute OSPF into BGP on R1 and back into OSPF on R9 — observe the routing loop, then resolve it using route tagging (tag) and a route-map filter to block re-imported routes
